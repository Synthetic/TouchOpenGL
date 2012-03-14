//
//  CTexture_Utilities.m
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CTexture_Utilities.h"

#if TARGET_OS_IPHONE
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#endif /* TARGET_OS_IPHONE */

#import "CFrameBuffer.h"

@implementation CTexture (CTexture_Utilities)

+ (id)textureWithCGImage:(CGImageRef)inImage size:(SIntSize)inSize format:(GLint)inFormat type:(GLint)inType error:(NSError **)outError
	{
	NSParameterAssert(inFormat == GL_RGBA || inFormat == GL_RGB);
	NSParameterAssert(inType == GL_UNSIGNED_BYTE);

	if (inSize.width != inSize.height)
		{
		NSLog(@"WARNING: Desired texture size isn't square.");
		}
		
    BOOL theFastPathFlag = NO;
	
	if (YES)
		{
		CGColorSpaceRef theColorSpace = CGImageGetColorSpace(inImage);
		const CGColorSpaceModel theModel = CGColorSpaceGetModel(theColorSpace);
		const CGImageAlphaInfo theAlphaInfo = CGImageGetAlphaInfo(inImage);
		const size_t theBitsPerComponent = CGImageGetBitsPerComponent(inImage);
		const CGSize theSize = (CGSize){ floor(CGImageGetWidth(inImage)), floor(CGImageGetHeight(inImage)) };

		if (inFormat == GL_RGBA && (theModel == kCGColorSpaceModelRGB) && (theAlphaInfo == kCGImageAlphaLast || theAlphaInfo == kCGImageAlphaPremultipliedLast || theAlphaInfo == kCGImageAlphaNoneSkipLast))
			{
			theFastPathFlag = YES;
			}

		if (inFormat == GL_RGB && (theModel == kCGColorSpaceModelRGB) && (theAlphaInfo == kCGImageAlphaNone))
			{
			theFastPathFlag = YES;
			}
		
		if (theBitsPerComponent != 8)
			{
			theFastPathFlag = YES;
			}
		
		if (theSize.width != inSize.width || theSize.height != inSize.height)
			{
			theFastPathFlag = NO;
			}
		
//		if (self.flip == YES)
//			{
//			theFastPathFlag = NO;
//			}
		}

    NSData *theData = NULL;
	if (theFastPathFlag)
		{
        theData = (__bridge_transfer NSData *)CGDataProviderCopyData(CGImageGetDataProvider(inImage));
		}
	else
		{
		NSUInteger theOctetsPerPixel = 0;
		CGImageAlphaInfo theAlphaInfo = kCGImageAlphaNone;
		if (inFormat == GL_RGBA)
			{
			theOctetsPerPixel = 4;
			theAlphaInfo = kCGImageAlphaPremultipliedLast;
			}
		else if (inFormat == GL_RGB)
			{
			theOctetsPerPixel = 3;
			theAlphaInfo = kCGImageAlphaNone;
			}
		
		NSUInteger theBitsPerChannel = 0;
		if (inType == GL_UNSIGNED_BYTE)
			{
			theBitsPerChannel = 8;
			}
		
        NSMutableData *theMutableData = [NSMutableData dataWithLength:inSize.width * theOctetsPerPixel * inSize.height];
        
        CGColorSpaceRef theColorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef theImageContext = CGBitmapContextCreate([theMutableData mutableBytes], inSize.width, inSize.height, theBitsPerChannel, inSize.width * theOctetsPerPixel, theColorSpace, theAlphaInfo);
        NSAssert(theImageContext != NULL, @"Should not have null context");

//        if (self.flip == YES)
//            {
//            CGContextTranslateCTM(theImageContext, 0, inSize.height);
//            CGContextScaleCTM(theImageContext, 1, -1);
//            }
        
        CGContextDrawImage(theImageContext, (CGRect){ .size = { .width = inSize.width, .height = inSize.height } }, inImage);
        CGContextRelease(theImageContext);
        
        CGColorSpaceRelease(theColorSpace);

        theData = theMutableData;
		}



    AssertOpenGLValidContext_();
    
    GLuint theName = 0;
	GLenum theTarget = GL_TEXTURE_2D;

    glGenTextures(1, &theName);
    
    AssertOpenGLNoError_();
    
    glBindTexture(theTarget, theName);

    // Configure texture...
	glTexParameteri(theTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(theTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(theTarget, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(theTarget, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);   


    // Update texture data...
    glTexImage2D(GL_TEXTURE_2D, 0, inFormat, inSize.width, inSize.height, 0, inFormat, inType, theData.bytes);

//    if (self.generateMipMap == YES)
//        {
//        glGenerateMipmap(GL_TEXTURE_2D);
//        }

    if (glIsTexture(theName) == GL_FALSE)
        {
        NSLog(@"Texture error.");
        }

    AssertOpenGLNoError_();

//    self.internalFormat = inFormat;
//    self.hasAlpha = YES;
//
//    AssertOpenGLNoError_();
//        
//    self.loaded = YES;
 
	CTexture *theTexture = [[CTexture alloc] initWithName:theName target:theTarget size:inSize];
	      
    return(theTexture);
	}

+ (id)textureWithCGImage:(CGImageRef)inImage error:(NSError **)outError
    {
    #pragma unused (outError)
    
    NSAssert(inImage != NULL, @"Seriously, we need an image!");
    
	const CGSize theSize = (CGSize){ floor(CGImageGetWidth(inImage)), floor(CGImageGetHeight(inImage)) };
//    SIntSize theDesiredSize = {
//        .width = exp2(ceil(log2(theSize.width))),
//        .height = exp2(ceil(log2(theSize.height))),
//        };
//    
//    // TODO conditionalize
//
//    theDesiredSize.width = theDesiredSize.height = MIN(MAX(theDesiredSize.width, theDesiredSize.height), 2048.0);

    SIntSize theDesiredSize = {
        .width = theSize.width,
        .height = theSize.height,
        };

	
	return([self textureWithCGImage:inImage size:theDesiredSize format:GL_RGBA type:GL_UNSIGNED_BYTE error:outError]);
    }

+ (id)textureNamed:(NSString *)inName error:(NSError *__autoreleasing *)outError
	{
	NSURL *theURL = [[NSBundle mainBundle].resourceURL URLByAppendingPathComponent:inName];
	return([self textureWithContentsOfURL:theURL error:outError]);
	}

+ (id)textureWithContentsOfURL:(NSURL *)inURL error:(NSError **)outError;
	{
	CGImageSourceRef theImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)inURL, NULL);
	if (theImageSource == NULL)
		{
		return(NULL);
		}

	CGImageRef theImage = CGImageSourceCreateImageAtIndex(theImageSource, 0, NULL);
	CFRelease(theImageSource);

	if (theImage == NULL)
		{
		return(NULL);
		}

	CTexture *theTexture = [self textureWithCGImage:theImage error:outError];
	theTexture.label = [inURL lastPathComponent];

	CFRelease(theImage);
	return(theTexture);
	}

#pragma mark -

- (CGImageRef)fetchImageViaFrameBuffer CF_RETURNS_RETAINED
	{
	AssertOpenGLValidContext_();
	AssertOpenGLNoError_();

	glBindTexture(self.target, self.name);

	// Store the current frame buffer...
	GLint theCurrentFrameBuffer = 0;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &theCurrentFrameBuffer);

	// Create a new frame buffer...
	CFrameBuffer *theFrameBuffer = [[CFrameBuffer alloc] initWithTarget:GL_FRAMEBUFFER];
	theFrameBuffer.label = [NSString stringWithFormat:@"Temporary texture framebuffer (%d)", theFrameBuffer.name];
	[theFrameBuffer bind];

	// Attach the texture (self) to it.
	[theFrameBuffer attachObject:self attachment:GL_COLOR_ATTACHMENT0];

	if (theFrameBuffer.isComplete == NO)
		{
		NSLog(@"Framebuffer not ready");
		return(NULL);
		}

	// GL read pixels from the frame buffer...
	CGImageRef theImage = [theFrameBuffer fetchImage:self.size];

	// Restore the old frame buffer...
    glBindFramebuffer(GL_FRAMEBUFFER, theCurrentFrameBuffer);

	AssertOpenGLNoError_();

	return(theImage);
	}

#if TARGET_OS_IPHONE == 0
- (CGImageRef)fetchImageDirect CF_RETURNS_RETAINED
	{
	glBindTexture(self.target, self.name);
	
	NSMutableData *theData = [NSMutableData dataWithLength:self.size.width * 4 * self.size.height];
	glGetTexImage(self.target, 0, GL_RGBA, GL_UNSIGNED_BYTE, theData.mutableBytes);

	CGColorSpaceRef theColorSpace = CGColorSpaceCreateDeviceRGB();
	
	const size_t width = self.size.width;
	const size_t height = self.size.height;
	const size_t bitsPerComponent = 8;
	const size_t bytesPerRow = width * (bitsPerComponent * 4) / 8;
	// TODO - probably dont want skip last
	CGBitmapInfo theBitmapInfo = kCGImageAlphaPremultipliedLast;
	
	CGContextRef theContext = CGBitmapContextCreateWithData(theData.mutableBytes, width, height, bitsPerComponent, bytesPerRow, theColorSpace, theBitmapInfo, NULL, NULL);
	
	CGImageRef theImage = CGBitmapContextCreateImage(theContext);
	
	// #########################################################################
	
	CFRelease(theContext);
	CFRelease(theColorSpace);

	return(theImage);
	}
#endif

- (CGImageRef)fetchImage CF_RETURNS_RETAINED
	{
	#if TARGET_OS_IPHONE
	return([self fetchImageViaFrameBuffer]);
	#else
	return([self fetchImageDirect]);
	#endif
	}


- (void)writeToFile:(NSString *)inPath
	{
	NSURL *theURL = [NSURL fileURLWithPath:inPath];
	
	[[NSFileManager defaultManager] createDirectoryAtURL:[theURL URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:NULL error:NULL];
	
	CGImageRef theImage = [self fetchImage];
	CGImageDestinationRef theDestination = CGImageDestinationCreateWithURL((__bridge CFURLRef)theURL, kUTTypePNG, 1, NULL);
	CGImageDestinationAddImage(theDestination, theImage, nil);
	CGImageDestinationFinalize(theDestination);
	CFRelease(theDestination);	
	CFRelease(theImage);
	}

@end

//
//  CTexture_Utilities.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 2/20/12.
//  Copyright 2012 Jonathan Wight. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Jonathan Wight.

#import "CTexture_Utilities.h"

#if TARGET_OS_IPHONE
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#endif /* TARGET_OS_IPHONE */

#import "CFrameBuffer.h"

@implementation CTexture (CTexture_Utilities)

+ (id)textureWithCGImage:(CGImageRef)inImage size:(SIntSize)inSize target:(GLenum)inTarget format:(GLint)inFormat type:(GLint)inType error:(NSError **)outError
	{
	NSParameterAssert(inImage != NULL);
	NSParameterAssert(inFormat == GL_RGBA || inFormat == GL_RGB || inFormat == GL_LUMINANCE);
	NSParameterAssert(inType == GL_UNSIGNED_BYTE);

//	if (inSize.width != inSize.height)
//		{
//		NSLog(@"WARNING: Desired texture size isn't square.");
//		}
		
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
        CGColorSpaceRef theColorSpace = NULL;
		NSUInteger theOctetsPerPixel = 0;
		CGImageAlphaInfo theAlphaInfo = kCGImageAlphaNone;
		if (inFormat == GL_RGBA)
			{
			theColorSpace = CGColorSpaceCreateDeviceRGB();
			theOctetsPerPixel = 4;
			theAlphaInfo = kCGImageAlphaPremultipliedLast;
			}
		else if (inFormat == GL_RGB)
			{
			theColorSpace = CGColorSpaceCreateDeviceRGB();
			theOctetsPerPixel = 3;
			theAlphaInfo = kCGImageAlphaNone;
			}
		else if (inFormat == GL_LUMINANCE)
			{
			theColorSpace = CGColorSpaceCreateDeviceGray();
			theOctetsPerPixel = 1;
			theAlphaInfo = kCGImageAlphaNone;
			}
		else
			{
			NSAssert(NO, @"Unknown format");
			}
		
		NSUInteger theBitsPerChannel = 0;
		if (inType == GL_UNSIGNED_BYTE)
			{
			theBitsPerChannel = 8;
			}
		
        NSMutableData *theMutableData = [NSMutableData dataWithLength:inSize.width * theOctetsPerPixel * inSize.height];
        
        
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

    glGenTextures(1, &theName);
    
    AssertOpenGLNoError_();
    
    glBindTexture(inTarget, theName);

    // Configure texture...
	glTexParameteri(inTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(inTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(inTarget, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(inTarget, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    // Update texture data...
	if (inTarget == GL_TEXTURE_2D)
		{
		glTexImage2D(inTarget, 0, inFormat, inSize.width, inSize.height, 0, inFormat, inType, theData.bytes);
		}
	#if TARGET_OS_IPHONE == 0
	else if (inTarget == GL_TEXTURE_1D)
		{
		glTexImage1D(inTarget, 0, inFormat, MAX(inSize.width, inSize.height), 0, inFormat, inType, theData.bytes);
		}
	#endif /* TARGET_OS_IPHONE == 0 */

    AssertOpenGLNoError_();



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
 
	CTexture *theTexture = [[CTexture alloc] initWithName:theName target:inTarget size:inSize format:inFormat type:inType owns:YES];
	      
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

	
	return([self textureWithCGImage:inImage size:theDesiredSize target:GL_TEXTURE_2D format:GL_RGBA type:GL_UNSIGNED_BYTE error:outError]);
    }

+ (id)textureNamed:(NSString *)inName error:(NSError *__autoreleasing *)outError
	{
	NSURL *theURL = [[NSBundle mainBundle].resourceURL URLByAppendingPathComponent:inName];
	return([self textureWithContentsOfURL:theURL error:outError]);
	}

+ (id)textureWithContentsOfURL:(NSURL *)inURL size:(SIntSize)inSize target:(GLenum)inTarget format:(GLint)inFormat type:(GLint)inType error:(NSError **)outError;
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

	CTexture *theTexture = [self textureWithCGImage:theImage size:inSize target:inTarget format:inFormat type:inType error:outError];
	theTexture.label = [inURL lastPathComponent];

	CFRelease(theImage);
	return(theTexture);
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
	

	CGColorSpaceRef theColorSpace = NULL;
	size_t theComponents = 0;
	size_t theBitsPerComponent = 0;
	CGBitmapInfo theBitmapInfo = 0;

	if (self.format == GL_RGBA)
		{
		theColorSpace = CGColorSpaceCreateDeviceRGB();
		theComponents = 4;
		theBitsPerComponent = 8;
		theBitmapInfo = kCGImageAlphaPremultipliedLast;
		}
	else if (self.format == GL_RGB)
		{
		theColorSpace = CGColorSpaceCreateDeviceRGB();
		theComponents = 3;
		theBitsPerComponent = 8;
		theBitmapInfo = kCGImageAlphaNone;
		}
	else if (self.format == GL_LUMINANCE)
		{
		theColorSpace = CGColorSpaceCreateDeviceGray();
		theComponents = 1;
		theBitsPerComponent = 8;
		theBitmapInfo = kCGImageAlphaNone;
		}
	else
		{
		NSLog(@"Cannot create texture. Unknown format.");
		return(NULL);
		}


	NSMutableData *theData = [NSMutableData dataWithLength:self.size.width * theComponents * self.size.height];
	glGetTexImage(self.target, 0, self.format, self.type, theData.mutableBytes);

	AssertOpenGLNoError_();
	
	const size_t theBytesPerRow = self.size.width * (theBitsPerComponent * theComponents) / 8;
	
	CGContextRef theContext = CGBitmapContextCreateWithData(theData.mutableBytes, self.size.width, self.size.height, theBitsPerComponent, theBytesPerRow, theColorSpace, theBitmapInfo, NULL, NULL);
	
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

#if TARGET_OS_IPHONE == 0
- (void)open
	{
	NSString *theTemporaryDirectory = NSTemporaryDirectory();
    NSString *theTemplate = [theTemporaryDirectory stringByAppendingPathComponent:@"XXXXXX.png"];
    char theBuffer[theTemplate.length + 1];
    strncpy(theBuffer, [theTemplate UTF8String], theTemplate.length + 1);
    int fd = mkstemps(theBuffer, 4);
	if (fd < 0)
		{
		NSLog(@"Could not create temp file. %d", errno);
		return;
		}
	NSString *thePath = [NSString stringWithUTF8String:theBuffer];
	[self writeToFile:thePath];
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:thePath]];
	}
#endif

@end

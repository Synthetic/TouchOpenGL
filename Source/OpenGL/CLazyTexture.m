//
//  CLazyTexture.m
//  ModelViewer_OSX
//
//  Created by Jonathan Wight on 04/04/11.
//  Copyright 2011 Inkling. All rights reserved.
//

#import "CLazyTexture.h"

#import "OpenGLTypes.h"

@interface CLazyTexture ()
@property (readwrite, nonatomic, assign) BOOL loaded;

//@property (readwrite, nonatomic, assign) GLuint name;
//@property (readwrite, nonatomic, assign) SIntSize size;
//@property (readwrite, nonatomic, assign) GLenum internalFormat;
//@property (readwrite, nonatomic, assign) GLboolean hasAlpha;

- (BOOL)loadWithImage:(CGImageRef)inImage error:(NSError **)outError;
@end

#pragma mark -

@implementation CLazyTexture

@synthesize image;
@synthesize flip;
@synthesize generateMipMap;

@synthesize loaded;

//@synthesize name;
//@synthesize size;
//@synthesize internalFormat;
//@synthesize hasAlpha;

- (id)initWithImage:(CGImageRef)inImage;
	{
	if ((self = [super init]) != NULL)
		{
        CFRetain(inImage);
        image = inImage;
        
        flip = NO;
        generateMipMap = NO;
		}
	return(self);
	}

- (void)dealloc
    {
    CFRelease(image);
    image = NULL;
    //
    [super dealloc];
    }

- (GLuint)name
    {
    if (self.loaded == NO)
        {
        [self loadWithImage:self.image error:NULL];
        }
    return([super name]);
    }

- (SIntSize)size
    {
    if (self.loaded == NO)
        {
        [self loadWithImage:self.image error:NULL];
        }
    return([super size]);
    }

- (GLenum)internalFormat
    {
    if (self.loaded == NO)
        {
        [self loadWithImage:self.image error:NULL];
        }
    return([super internalFormat]);
    }

- (GLboolean)hasAlpha
    {
    if (self.loaded == NO)
        {
        [self loadWithImage:self.image error:NULL];
        }
    return([super hasAlpha]);
    }

- (BOOL)loadWithImage:(CGImageRef)inImage error:(NSError **)outError
    {
    #pragma unused (outError)
    
    NSAssert(inImage != NULL, @"Seriously, we need an image!");
    
    CGColorSpaceRef theColorSpace = CGImageGetColorSpace(inImage);
    const CGColorSpaceModel theModel = CGColorSpaceGetModel(theColorSpace);
    const CGImageAlphaInfo theAlphaInfo = CGImageGetAlphaInfo(inImage);
    const size_t theBitsPerComponent = CGImageGetBitsPerComponent(inImage);

    const CGSize theSize = (CGSize){ floor(CGImageGetWidth(inImage)), floor(CGImageGetHeight(inImage)) };

    GLint theFormat = 0;
    GLint theType = 0;

    NSData *theData = NULL;

    // Convert to power of 2
    // TODO conditionalize
    SIntSize theDesiredSize = {
        .width = exp2(ceil(log2(theSize.width))),
        .height = exp2(ceil(log2(theSize.height))),
        };
    
    // TODO conditionalize

    theDesiredSize.width = theDesiredSize.height = MIN(MAX(theDesiredSize.width, theDesiredSize.height), 2048.0);
    
    
    const BOOL theFastPathFlag = ((theModel == kCGColorSpaceModelRGB) && (theAlphaInfo == kCGImageAlphaLast || theAlphaInfo == kCGImageAlphaPremultipliedLast) && (theBitsPerComponent == 8) && (theSize.width == theDesiredSize.width) && (theSize.height == theDesiredSize.height) && self.flip == NO);
    
    if (theFastPathFlag == YES)
        {
        theFormat = GL_RGBA;
        theType = GL_UNSIGNED_BYTE;
        theData = [(NSData *)CGDataProviderCopyData(CGImageGetDataProvider(inImage)) autorelease];
        }


    if (theData == NULL)
        {
        theFormat = GL_RGBA;
        theType = GL_UNSIGNED_BYTE;
        
        NSLog(@"Warning, converting texture.");
        
        NSMutableData *theMutableData = [NSMutableData dataWithLength:theDesiredSize.width * 4 * theDesiredSize.height];
        theData = theMutableData;
        
        CGColorSpaceRef theColorspace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef theImageContext = CGBitmapContextCreate([theMutableData mutableBytes], theDesiredSize.width, theDesiredSize.height, 8, theDesiredSize.width * 4, theColorSpace, kCGImageAlphaPremultipliedLast);
        NSAssert(theImageContext != NULL, @"Should not have null context");

        if (self.flip == YES)
            {
            CGContextTranslateCTM(theImageContext, 0, theDesiredSize.height);
            CGContextScaleCTM(theImageContext, 1, -1);
            }
        
        CGContextDrawImage(theImageContext, (CGRect){ .size = { .width = theDesiredSize.width, .height = theDesiredSize.height } }, inImage);
        CGContextRelease(theImageContext);
        
        CGColorSpaceRelease(theColorspace);
        }

    if (theFormat == 0 || theType == 0)
        {
        NSLog(@"No format!");
        return(NO);
        }
      
    if (theData == NULL)
        {
        NSLog(@"No data!");
        return(NO);
        }
        
    if (theData.length != theDesiredSize.width * theDesiredSize.height * 4)
        {
        NSLog(@"Wrong data length");
        return(NO);
        }
      
    AssertOpenGLValidContext_();
    
    GLuint theName = 0;

    glGenTextures(1, &theName);
    
    AssertOpenGLNoError_();
    
    glBindTexture(GL_TEXTURE_2D, theName);

    // Configure texture...
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    // Update texture data...
    glTexImage2D(GL_TEXTURE_2D, 0, theFormat, (GLsizei)theDesiredSize.width, (GLsizei)theDesiredSize.height, 0, theFormat, theType, theData.bytes);

    if (self.generateMipMap == YES)
        {
        glGenerateMipmap(GL_TEXTURE_2D);
        }

    if (glIsTexture(theName) == GL_FALSE)
        {
        NSLog(@"Texture error.");
        }

    AssertOpenGLNoError_();

    self.name = theName;
    self.size = theDesiredSize;
    self.internalFormat = theFormat;
    self.hasAlpha = YES;

    glBindTexture(GL_TEXTURE_2D, 0);

    AssertOpenGLNoError_();
        
    self.loaded = YES;
    
    return(YES);
    }

@end

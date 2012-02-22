//
//  CLazyTexture.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 04/04/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
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

#import "CLazyTexture.h"

#if TARGET_OS_IPHONE == 1
#import <ImageIO/ImageIO.h>
#endif /* TARGET_OS_IPHONE == 1 */

#import "OpenGLTypes.h"

@interface CLazyTexture ()
@property (readwrite, nonatomic, assign) BOOL loaded;

//@property (readwrite, nonatomic, assign) GLuint name;
//@property (readwrite, nonatomic, assign) SIntSize size;
//@property (readwrite, nonatomic, assign) GLenum internalFormat;
//@property (readwrite, nonatomic, assign) GLboolean hasAlpha;

- (BOOL)loadWithImage:(CGImageRef)inImage size:(SIntSize)inSize format:(GLint)inFormat type:(GLint)inType error:(NSError **)outError;
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

- (id)initWithImage:(CGImageRef)inImage flip:(BOOL)inFlip generateMipMap:(BOOL)inGenerateMipMap;
	{
	if ((self = [super init]) != NULL)
		{
        CFRetain(inImage);
        image = inImage;
        
        flip = inFlip;
        generateMipMap = inGenerateMipMap;
		}
	return(self);
	}

- (id)initWithURL:(NSURL *)inURL flip:(BOOL)inFlip generateMipMap:(BOOL)inGenerateMipMap
    {
    CGImageRef theImage = NULL;
    
    NSMutableDictionary *theCreationOptions = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:NO], kCGImageSourceShouldCache,
        NULL];
                
    CGImageSourceRef theSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)inURL, (__bridge CFDictionaryRef)theCreationOptions);
    theImage = CGImageSourceCreateImageAtIndex(theSourceRef, 0, (__bridge CFDictionaryRef)theCreationOptions);
    CFRelease(theSourceRef);

    if (theImage == NULL)
        {
        self = NULL;
        return(NULL);
        }
    
    if ((self = [self initWithImage:theImage flip:inFlip generateMipMap:inGenerateMipMap]) != NULL)
        {
        }
    return self;
    }

- (void)dealloc
    {
    CFRelease(image);
    image = NULL;
    }

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (%@)", [super description], self.image]);
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

- (BOOL)loadWithImage:(CGImageRef)inImage size:(SIntSize)inSize format:(GLint)inFormat type:(GLint)inType error:(NSError **)outError
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
		
		if (self.flip == YES)
			{
			theFastPathFlag = NO;
			}
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

        if (self.flip == YES)
            {
            CGContextTranslateCTM(theImageContext, 0, inSize.height);
            CGContextScaleCTM(theImageContext, 1, -1);
            }
        
        CGContextDrawImage(theImageContext, (CGRect){ .size = { .width = inSize.width, .height = inSize.height } }, inImage);
        CGContextRelease(theImageContext);
        
        CGColorSpaceRelease(theColorSpace);

        theData = theMutableData;
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
    glTexImage2D(GL_TEXTURE_2D, 0, inFormat, inSize.width, inSize.height, 0, inFormat, inType, theData.bytes);

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
    self.size = inSize;
    self.internalFormat = inFormat;
    self.hasAlpha = YES;

    AssertOpenGLNoError_();
        
    self.loaded = YES;
    
    return(YES);
	}


- (BOOL)loadWithImage:(CGImageRef)inImage error:(NSError **)outError
    {
    #pragma unused (outError)
    
    NSAssert(inImage != NULL, @"Seriously, we need an image!");
    
	const CGSize theSize = (CGSize){ floor(CGImageGetWidth(inImage)), floor(CGImageGetHeight(inImage)) };
    SIntSize theDesiredSize = {
        .width = exp2(ceil(log2(theSize.width))),
        .height = exp2(ceil(log2(theSize.height))),
        };
    
    // TODO conditionalize

    theDesiredSize.width = theDesiredSize.height = MIN(MAX(theDesiredSize.width, theDesiredSize.height), 2048.0);
	
	return([self loadWithImage:inImage size:theDesiredSize format:GL_RGBA type:GL_UNSIGNED_BYTE error:outError]);
    }

@end

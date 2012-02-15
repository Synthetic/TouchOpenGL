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

#import <ImageIO/ImageIO.h>

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
    
    if ((self = [self initWithImage:theImage]) != NULL)
        {
        flip = inFlip;
        generateMipMap = inGenerateMipMap;
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

- (BOOL)loadWithImage:(CGImageRef)inImage error:(NSError **)outError
    {
    #pragma unused (outError)
    
    NSLog(@"%@", self);


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
        theData = (__bridge_transfer NSData *)CGDataProviderCopyData(CGImageGetDataProvider(inImage));
        }


    if (theData == NULL)
        {
        theFormat = GL_RGBA;
        theType = GL_UNSIGNED_BYTE;
        
        NSLog(@"Warning, converting texture.");
        NSLog(@"Color Model: %d, Alpha Info: %d, Bits Per Components: %lu, Width: %g, Height: %g", theModel, theAlphaInfo, theBitsPerComponent, theSize.width, theSize.height);
        
        
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

//
//  CCoreVideoTexture.m
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/23/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CCoreVideoTexture.h"

#import "COpenGLContext.h"
#import "COpenGLContext_CoreVideoExtensions.h"

@interface CCoreVideoTexture ()
@property (readwrite, nonatomic, assign) CVOpenGLESTextureRef texture;
@end

#pragma mark -

@implementation CCoreVideoTexture

- (id)initWithCVImageBuffer:(CVImageBufferRef)inImageBuffer
	{
	AssertOpenGLValidContext_();
	
	const SIntSize theSize = {
		.width = CVPixelBufferGetWidth(inImageBuffer),
		.height = CVPixelBufferGetHeight(inImageBuffer),
		};
	
	CVOpenGLESTextureRef theTexture = NULL;
    CVReturn theError = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [COpenGLContext currentContext].textureCache,
		inImageBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, theSize.width, theSize.height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &theTexture);
	if (theError != kCVReturnSuccess || theTexture == NULL)
		{
		self = NULL;
		return(NULL);
		}

//	GLenum theTarget = CVOpenGLESTextureGetTarget(theTexture);
	GLenum theName = CVOpenGLESTextureGetName(theTexture);
//	BOOL theIsFlippedFlag = CVOpenGLESTextureisFlipped(theTexture);

	glBindTexture(GL_TEXTURE_2D, theName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);   

	#warning GL_RGBA != GL_BGRA
    if ((self = [self initWithName:theName target:GL_TEXTURE_2D size:theSize format:GL_RGBA type:GL_UNSIGNED_BYTE owns:NO]) != NULL)
        {
		_imageBuffer = inImageBuffer;
		CFRetain(_imageBuffer);
		
		_texture = theTexture;
        }
    return self;
    }

- (id)initWithSize:(SIntSize)inSize
	{
	NSDictionary *theAttributes = @{ (__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{} };
	
	CVPixelBufferRef thePixelBuffer;
	CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, inSize.width, inSize.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)theAttributes, &thePixelBuffer);
	if (theError != kCVReturnSuccess)
		{
		NSLog(@"Failure");
		self = NULL;
		return(self);
		}
	if ((self = [self initWithCVImageBuffer:thePixelBuffer]) != NULL)
		{
		_imageBuffer = thePixelBuffer;
		}
		
	return(self);
	}

- (void)invalidate
	{
	if (_imageBuffer)
		{
		CFRelease(_imageBuffer);
		_imageBuffer = NULL;
		}
	
	if (_texture)
		{
		CFRelease(_texture);
		_texture = NULL;
		}

	[super invalidate];
	}
	
/*
- (CGImageRef)fetchImage CF_RETURNS_RETAINED
	{
//	CVReturn theResult = CVPixelBufferLockBaseAddress(self.texture, kCVPixelBufferLock_ReadOnly);
//	if (theResult != kCVReturnSuccess)
//		{
//		return(NULL);
//		}

	uint8_t *thePixels = (uint8_t*)CVPixelBufferGetBaseAddress(self.texture);

	const size_t width = self.size.width;
	const size_t height = self.size.height;
	const size_t bitsPerComponent = 8;
	const size_t bytesPerRow = width * (bitsPerComponent * 4) / 8;
	// TODO - probably dont want skip last
	CGBitmapInfo theBitmapInfo = kCGImageAlphaPremultipliedLast;

	CGColorSpaceRef theColorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef theContext = CGBitmapContextCreateWithData(thePixels, width, height, bitsPerComponent, bytesPerRow, theColorSpace, theBitmapInfo, NULL, NULL);
	
	CGImageRef theImage = CGBitmapContextCreateImage(theContext);
	
	// #########################################################################
	
	CFRelease(theContext);
	CFRelease(theColorSpace);

//	CVPixelBufferUnlockBaseAddress(self.texture, kCVPixelBufferLock_ReadOnly);

	return(theImage);
 	}
*/

@end

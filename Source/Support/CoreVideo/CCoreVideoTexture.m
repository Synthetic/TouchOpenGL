//
//  CCoreVideoTexture.m
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/23/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CCoreVideoTexture.h"

@interface CCoreVideoTexture ()
@property (readwrite, nonatomic, assign) CVOpenGLESTextureCacheRef textureCache;
@property (readwrite, nonatomic, assign) CVOpenGLESTextureRef texture;
@end

#pragma mark -

@implementation CCoreVideoTexture

- (id)initWithCVImageBuffer:(CVImageBufferRef)inImageBuffer textureCache:(CVOpenGLESTextureCacheRef)inTextureCache
	{
	AssertOpenGLValidContext_();
	
	const SIntSize theSize = {
		.width = CVPixelBufferGetWidth(inImageBuffer),
		.height = CVPixelBufferGetHeight(inImageBuffer),
		};
	
	CVOpenGLESTextureRef theTexture = NULL;
    CVReturn theError = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, inTextureCache,
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

	
    if ((self = [self initWithName:theName target:GL_TEXTURE_2D size:theSize owns:NO]) != NULL)
        {
		_textureCache = (CVOpenGLESTextureCacheRef)CFRetain(inTextureCache);
		_texture = theTexture;
        }
    return self;
    }

- (id)initWithSize:(SIntSize)inSize textureCache:(CVOpenGLESTextureCacheRef)inTextureCache
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
	if ((self = [self initWithCVImageBuffer:thePixelBuffer textureCache:inTextureCache]) != NULL)
		{
		}
		
	CFRelease(thePixelBuffer);
		
	return(self);
	}

- (void)invalidate
	{
	if (_texture)
		{
		CFRelease(_texture);
		_texture = NULL;
		}

	if (_textureCache)
		{
		CVOpenGLESTextureCacheFlush(_textureCache, 0);

		CFRelease(_textureCache);
		_textureCache = NULL;
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

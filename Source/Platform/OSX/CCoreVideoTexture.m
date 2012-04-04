//
//  CCoreVideoTexture.m
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/23/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CCoreVideoTexture.h"

@interface CCoreVideoTexture ()
@property (readwrite, nonatomic, assign) CVOpenGLTextureCacheRef textureCache;
@property (readwrite, nonatomic, assign) CVOpenGLTextureRef texture;
@end

#pragma mark -

@implementation CCoreVideoTexture

- (id)initWithCVImageBuffer:(CVImageBufferRef)inImageBuffer textureCache:(CVOpenGLTextureCacheRef)inTextureCache
	{
	AssertOpenGLValidContext_();
	
	const SIntSize theSize = {
		.width = CVPixelBufferGetWidth(inImageBuffer),
		.height = CVPixelBufferGetHeight(inImageBuffer),
		};
	
	CVOpenGLTextureRef theTexture = NULL;
    CVReturn theError = CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, inTextureCache, inImageBuffer, NULL, &theTexture);
	if (theError != kCVReturnSuccess || theTexture == NULL)
		{
		self = NULL;
		return(NULL);
		}
		
	GLenum theName = CVOpenGLTextureGetName(theTexture);
//	BOOL theIsFlippedFlag = CVOpenGLTextureisFlipped(theTexture);

	GLenum theTarget = CVOpenGLTextureGetTarget(theTexture);
	
	glBindTexture(theTarget, theName);

	AssertOpenGLNoError_();

	glTexParameteri(theTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(theTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(theTarget, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(theTarget, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);   

	AssertOpenGLNoError_();

	#warning TODO - do not assume.
	GLenum theFormat = GL_RGBA;
	GLenum theType = GL_UNSIGNED_BYTE;
	
    if ((self = [self initWithName:theName target:theTarget size:theSize format:theFormat type:theType owns:NO]) != NULL)
        {
		_textureCache = (CVOpenGLTextureCacheRef)CFRetain(inTextureCache);
		_texture = theTexture;
        }
    return self;
    }

- (id)initWithSize:(SIntSize)inSize textureCache:(CVOpenGLTextureCacheRef)inTextureCache
	{
	NSDictionary *theAttributes = @{
		(__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{},
		(__bridge NSString *)kCVPixelBufferOpenGLCompatibilityKey: @YES,
		};
	CVPixelBufferRef thePixelBuffer = NULL;
	CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, inSize.width, inSize.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)theAttributes, &thePixelBuffer);
	if (theError != kCVReturnSuccess)
		{
		NSLog(@"Failure");
		self = NULL;
		return(self);
		}

	if ((self = [self initWithCVImageBuffer:thePixelBuffer textureCache:inTextureCache]) != NULL)
		{
		_pixelBuffer = thePixelBuffer;
		}
		
	return(self);
	}

- (void)invalidate
	{
	if (_pixelBuffer)
		{
		CFRelease(_pixelBuffer);
		_pixelBuffer = NULL;
		}
	
	if (_texture)
		{
		CFRelease(_texture);
		_texture = NULL;
		}

	if (_textureCache)
		{
		CVOpenGLTextureCacheFlush(_textureCache, 0);

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

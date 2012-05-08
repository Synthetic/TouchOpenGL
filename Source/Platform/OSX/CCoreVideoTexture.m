//
//  CCoreVideoTexture.m
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/23/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CCoreVideoTexture.h"

#import "COpenGLContext_CoreVideoExtensions.h"

@interface CCoreVideoTexture ()
@property (readwrite, nonatomic, assign) CVOpenGLTextureRef texture;
@end

#pragma mark -

@implementation CCoreVideoTexture

- (id)initWithCVPixelBuffer:(CVPixelBufferRef)inPixelBuffer
	{
	AssertOpenGLValidContext_();
	
	const SIntSize theSize = {
		.width = (GLint)CVPixelBufferGetWidth(inPixelBuffer),
		.height = (GLint)CVPixelBufferGetHeight(inPixelBuffer),
		};
	
	CVOpenGLTextureRef theTexture = NULL;
    CVReturn theError = CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [COpenGLContext currentContext].textureCache, inPixelBuffer, NULL, &theTexture);
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
		_texture = theTexture;

		CFRetain(inPixelBuffer);
		_pixelBuffer = inPixelBuffer;
        }
    return self;
    }

- (id)initWithSize:(SIntSize)inSize pixelFormat:(OSType)inPixelFormat
	{
	NSDictionary *theAttributes = @{
		(__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{},
		(__bridge NSString *)kCVPixelBufferOpenGLCompatibilityKey: @YES,
		};
	CVPixelBufferRef thePixelBuffer = NULL;
	CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, inSize.width, inSize.height, inPixelFormat, (__bridge CFDictionaryRef)theAttributes, &thePixelBuffer);
	if (theError != kCVReturnSuccess)
		{
		NSLog(@"CVPixelBufferCreate() failed with %d", theError);
		self = NULL;
		return(self);
		}

	if ((self = [self initWithCVPixelBuffer:thePixelBuffer]) != NULL)
		{
		}
	
	CFRelease(thePixelBuffer);
	
	return(self);
	}

- (id)initWithSize:(SIntSize)inSize
	{
	return([self initWithSize:inSize pixelFormat:kCVPixelFormatType_32BGRA]);
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

	[super invalidate];
	}

- (CGImageRef)fetchImage CF_RETURNS_RETAINED
	{
	const OSType thePixelFormat = CVPixelBufferGetPixelFormatType(self.pixelBuffer);
	const size_t theBytesPerRow = CVPixelBufferGetBytesPerRow(self.pixelBuffer);

	size_t theBitsPerComponent = 0;
	CGBitmapInfo theBitmapInfo = 0;
	CGColorSpaceRef theColorSpace = NULL;

	if (thePixelFormat == kCVPixelFormatType_32BGRA)
		{
		theBitsPerComponent = 8;
		theBitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little;
		theColorSpace = CGColorSpaceCreateDeviceRGB();
		}
	else
		{
		NSLog(@"Error: Unknown pixel format: %X", thePixelFormat);
		return(NULL);
		}


	CVReturn theResult = CVPixelBufferLockBaseAddress(self.pixelBuffer, kCVPixelBufferLock_ReadOnly);
	if (theResult != kCVReturnSuccess)
		{
		CFRelease(theColorSpace);
		return(NULL);
		}

	void *thePixels = CVPixelBufferGetBaseAddress(self.pixelBuffer);
	CGContextRef theContext = CGBitmapContextCreateWithData(thePixels, self.size.width, self.size.height, theBitsPerComponent, theBytesPerRow, theColorSpace, theBitmapInfo, NULL, NULL);
	CGImageRef theImage = CGBitmapContextCreateImage(theContext);
	
	// #########################################################################
	
	CFRelease(theContext);
	CFRelease(theColorSpace);

	CVPixelBufferUnlockBaseAddress(self.texture, kCVPixelBufferLock_ReadOnly);

	return(theImage);
 	}

@end

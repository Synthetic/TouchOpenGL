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

#define USE_GLREADPIXELS (TARGET_IPHONE_SIMULATOR == 1)

@interface CCoreVideoTexture ()
@property (readwrite, nonatomic, assign) CVOpenGLESTextureRef texture;
@end

#pragma mark -

@implementation CCoreVideoTexture

@synthesize pixelBuffer = _pixelBuffer;

- (id)initWithCVPixelBuffer:(CVPixelBufferRef)inPixelBuffer
	{
	AssertOpenGLValidContext_();
	
	const SIntSize theSize = {
		.width = CVPixelBufferGetWidth(inPixelBuffer),
		.height = CVPixelBufferGetHeight(inPixelBuffer),
		};

	const GLenum theTarget = GL_TEXTURE_2D;
	GLenum theFormat;
	const GLenum theType = GL_UNSIGNED_BYTE;
	const GLenum theInternalFormat = GL_RGBA;
	
	const OSType thePixelFormat = CVPixelBufferGetPixelFormatType(inPixelBuffer);
	if (thePixelFormat == kCVPixelFormatType_32BGRA)
		{
		theFormat = GL_BGRA;
		}
	else
		{
		NSAssert(NO, @"Unsupported pixel format.");
		}
	
	CVOpenGLESTextureRef theTexture = NULL;
    CVReturn theError = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [COpenGLContext currentContext].textureCache,
		inPixelBuffer, NULL, theTarget, theInternalFormat, theSize.width, theSize.height, theFormat, theType, 0, &theTexture);
	if (theError != kCVReturnSuccess || theTexture == NULL)
		{
		self = NULL;
		return(NULL);
		}

	GLenum theName = CVOpenGLESTextureGetName(theTexture);

//	BOOL theIsFlippedFlag = CVOpenGLESTextureisFlipped(theTexture);

	glBindTexture(theTarget, theName);
	glTexParameteri(theTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(theTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(theTarget, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(theTarget, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    if ((self = [self initWithName:theName target:theTarget size:theSize format:theFormat type:theType owns:NO]) != NULL)
        {
		_pixelBuffer = inPixelBuffer;
		CFRetain(_pixelBuffer);
		
		_texture = theTexture;
        }
    return self;
    }

- (id)initWithSize:(SIntSize)inSize
	{
	NSDictionary *theAttributes = @{
		(__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{},
		(__bridge NSString *)kCVPixelBufferOpenGLCompatibilityKey: @1,
		};
	
	CVPixelBufferRef thePixelBuffer = NULL;
	CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, inSize.width, inSize.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)theAttributes, &thePixelBuffer);
	if (theError != kCVReturnSuccess)
		{
		NSLog(@"Failure");
		self = NULL;
		return(self);
		}
	if ((self = [self initWithCVPixelBuffer:thePixelBuffer]) != NULL)
		{
		}
		
	return(self);
	}

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (pixel buffer: %p, texture: %p)", [super description], self.pixelBuffer, self.texture]);
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

#if USE_GLREADPIXELS == 1
- (CVPixelBufferRef)pixelBuffer
	{
	// On the simulator pixel buffer backed textures do not work properly - so we have to manually copy texture contents (via a framebuffer & glReadPixel) into the pixel buffer...

	AssertOpenGLNoError_();

	// Store the current frame buffer...
	GLint theCurrentFrameBuffer = 0;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &theCurrentFrameBuffer);
	
	GLuint theFrameBuffer = 0;
	glGenFramebuffers(1, &theFrameBuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, theFrameBuffer);
	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, self.target, self.name, 0);

	// Make sure we have a valid frame buffer...
	GLenum theFramebufferStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	if (theFramebufferStatus != GL_FRAMEBUFFER_COMPLETE)
		{
		NSLog(@"Framebuffer not complete: %x", theFramebufferStatus);
		return(NULL);
		}

	CVPixelBufferLockBaseAddress(_pixelBuffer, kCVPixelBufferLock_ReadOnly);
	void *theBaseAddress = CVPixelBufferGetBaseAddress(_pixelBuffer);
	glReadPixels(0, 0, self.size.width, self.size.height, GL_BGRA, GL_UNSIGNED_BYTE, theBaseAddress);
	CVPixelBufferUnlockBaseAddress(_pixelBuffer, kCVPixelBufferLock_ReadOnly);
	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, self.target, 0, 0);
	
	glBindFramebuffer(GL_FRAMEBUFFER, theCurrentFrameBuffer);

	glDeleteFramebuffers(1, &theFrameBuffer);

	AssertOpenGLNoError_();
	
	return(_pixelBuffer);
	}
#endif /* USE_GLREADPIXELS == 1 */

- (CGImageRef)fetchImage CF_RETURNS_RETAINED
	{
//	[self set:(Color4f){ 2.0, 4.0, 6.0, 8.0 }];
	
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
		NSLog(@"Error: Unknown pixel format: %lu", thePixelFormat);
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

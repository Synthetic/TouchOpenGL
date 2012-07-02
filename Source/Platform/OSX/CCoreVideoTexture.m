//
//  CCoreVideoTexture.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 2/23/12.
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

//	#warning TODO - do not assume.
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

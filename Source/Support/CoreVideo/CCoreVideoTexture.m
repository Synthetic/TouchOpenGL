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
	
	SIntSize theSize = {
		.width = CVPixelBufferGetWidth(inImageBuffer),
		.height = CVPixelBufferGetHeight(inImageBuffer),
		};
	
	CVOpenGLESTextureRef theTexture = NULL;
    CVReturn theError = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, inTextureCache,
		inImageBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, theSize.width, theSize.height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &theTexture);
	if (theError != kCVReturnSuccess)
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

	
    if ((self = [self initWithName:theName size:theSize owns:NO]) != NULL)
        {
		_textureCache = (CVOpenGLESTextureCacheRef)CFRetain(inTextureCache);
		_texture = theTexture;
        }
    return self;
    }

- (void)dealloc
	{
	if (_textureCache)
		{
		CVOpenGLESTextureCacheFlush(_textureCache, 0);

		CFRelease(_textureCache);
		}
	if (_texture)
		{
		CFRelease(_texture);
		}
	}


@end

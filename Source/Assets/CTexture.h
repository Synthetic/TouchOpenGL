//
//  CTexture.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/06/10.
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

#import <Foundation/Foundation.h>

#import "OpenGLIncludes.h"
#import "OpenGLTypes.h"
#import "COpenGLAsset.h"

@interface CTexture : COpenGLAsset

@property (readonly, nonatomic, assign) GLenum target; // e.g. GL_TEXTURE_2D
@property (readonly, nonatomic, assign) GLenum format; // e.g. GL_RGBA
@property (readonly, nonatomic, assign) GLenum type; // e.g. GL_UNSIGNED_BYTE
@property (readonly, nonatomic, assign) SIntSize size;

- (id)initWithName:(GLuint)inName target:(GLenum)inTarget size:(SIntSize)inSize format:(GLenum)inFormat type:(GLenum)inType owns:(BOOL)inOwns;

- (id)initWithTarget:(GLenum)inTarget size:(SIntSize)inSize format:(GLenum)inFormat type:(GLenum)inType;

- (BOOL)isValid;

- (void)bind;

- (void)use:(GLuint)inUniform index:(GLuint)inIndex;

- (void)set:(Color4f)inColor;

@end

#pragma mark -

@interface CTexture (CTexture_Utilities)

+ (id)textureWithCGImage:(CGImageRef)inImage size:(SIntSize)inSize target:(GLenum)inTarget format:(GLint)inFormat type:(GLint)inType error:(NSError **)outError;
+ (id)textureWithCGImage:(CGImageRef)inImage error:(NSError **)outError;

+ (id)textureNamed:(NSString *)inName error:(NSError **)outError;

+ (id)textureWithContentsOfURL:(NSURL *)inURL size:(SIntSize)inSize target:(GLenum)inTarget format:(GLint)inFormat type:(GLint)inType error:(NSError **)outError;
+ (id)textureWithContentsOfURL:(NSURL *)inURL error:(NSError **)outError;

- (CGImageRef)fetchImageViaFrameBuffer CF_RETURNS_RETAINED;
- (CGImageRef)fetchImage CF_RETURNS_RETAINED;

- (void)writeToFile:(NSString *)inPath;

#if TARGET_OS_IPHONE == 0
- (void)open;
#endif

@end

//
//  CTexture.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/06/10.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
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
//  or implied, of toxicsoftware.com.

#import "CTexture.h"

@interface CTexture ()
@property (readwrite, nonatomic, assign) BOOL owns;
@end

@implementation CTexture

+ (GLenum)type
	{
	return(GL_TEXTURE);
	}

- (id)initWithName:(GLuint)inName target:(GLenum)inTarget size:(SIntSize)inSize owns:(BOOL)inOwns
	{
    if ((self = [super initWithName:inName]) != NULL)
        {
        _size = inSize;
		_target = inTarget;
        _owns = inOwns;
        }
    return(self);
	}

- (id)initWithName:(GLuint)inName target:(GLenum)inTarget size:(SIntSize)inSize
    {
	return([self initWithName:inName target:inTarget size:inSize owns:YES]);
    }

- (id)initWithTarget:(GLenum)inTarget size:(SIntSize)inSize format:(GLenum)inFormat type:(GLenum)inType
	{
	AssertOpenGLValidContext_();
	AssertOpenGLNoError_();

	if (inSize.width != inSize.height)
		{
		NSLog(@"WARNING: Texture request isn't square.");
		}
	
	GLuint theTextureName;
	glGenTextures(1, &theTextureName);
	glBindTexture(inTarget, theTextureName);
	glTexImage2D(inTarget, 0, inFormat, inSize.width, inSize.height, 0, inFormat, inType, NULL); 
	glTexParameteri(inTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(inTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(inTarget, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(inTarget, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);   

	AssertOpenGLNoError_();

    if ((self = [self initWithName:theTextureName target:inTarget size:inSize owns:YES]) != NULL)
        {
        }
    return(self);
	}

- (id)initWithSize:(SIntSize)inSize
	{
	return([self initWithTarget:GL_TEXTURE_2D size:inSize format:GL_RGBA type:GL_UNSIGNED_BYTE]);
	}

//- (NSString *)description
//    {
//    return([NSString stringWithFormat:@"%@ (name: %d, %d x %d)", [super description], self.name, self.size.width, self.size.height]);
//    }

- (GLuint)cost
	{
	return(self.size.width * self.size.height);
	}

- (void)invalidate
	{
	AssertOpenGLValidContext_();

    if (_owns == YES && glIsTexture(self.name))
        {
		GLuint theName = self.name;
        glDeleteTextures(1, &theName);
		_owns = NO;
        }

	[super invalidate];
	}

- (BOOL)isValid
    {
    return(glIsTexture(self.name));
    }

- (void)bind
	{
	glBindTexture(self.target, self.name);
	}

- (void)use:(GLuint)inUniform index:(GLuint)inIndex
	{
	AssertOpenGLValidContext_();
	
	glActiveTexture(GL_TEXTURE0 + inIndex);
	glBindTexture(self.target, self.name);
	glUniform1i(inUniform, inIndex);
	AssertOpenGLNoError_();
	}

+ (BOOL)debug
	{
	return(NO);
	}
    
@end

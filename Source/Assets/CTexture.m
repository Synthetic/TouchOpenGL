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
@property (readwrite, nonatomic, assign) BOOL named;
@end

@implementation CTexture

@synthesize name;
@synthesize size;
@synthesize internalFormat;
@synthesize hasAlpha;
@synthesize textureUnit;

@synthesize named;

- (id)initWithName:(GLuint)inName size:(SIntSize)inSize
    {
    if ((self = [super init]) != NULL)
        {
        name = inName;
        size = inSize;
        named = YES;
        textureUnit = GL_TEXTURE0;
        }
    return(self);
    }

- (id)initWithSize:(SIntSize)inSize
	{
	GLuint theTextureName;
	glGenTextures(1, &theTextureName);
	glBindTexture(GL_TEXTURE_2D, theTextureName);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, inSize.width, inSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL); 

	AssertOpenGLNoError_();

    if ((self = [self initWithName:theTextureName size:inSize]) != NULL)
        {
        }
    return(self);
	}

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (name: %d (named: %d), %d x %d, texture unit: %d)", [super description], self.name, self.named, self.size.width, self.size.height, self.textureUnit]);
    }

- (void)dealloc
    {
    if (named == YES && glIsTexture(name))
        {
        glDeleteTextures(1, &name);
        name = 0;
		named = NO;
        }
    }

- (void)setName:(GLuint)inName
	{
	if (name != inName)
		{
		name = inName;
		self.named = YES;
		}
	}

- (BOOL)isValid
    {
    return(glIsTexture(self.name));
    }

- (void)use:(GLuint)inUniform
	{
	glActiveTexture(self.textureUnit);
	glBindTexture(GL_TEXTURE_2D, self.name);
    GLuint theTextureUnitIndex = 0;
    switch (self.textureUnit)
        {
        case GL_TEXTURE0:
            theTextureUnitIndex = 0;
            break;
        case GL_TEXTURE1:
            theTextureUnitIndex = 1;
            break;
        }
    
    glUniform1i(inUniform, theTextureUnitIndex);
	}
    
@end

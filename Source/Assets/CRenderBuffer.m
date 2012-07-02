//
//  CRenderBuffer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 02/15/11.
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

#import "CRenderBuffer.h"


@implementation CRenderBuffer

@synthesize name;

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        glGenRenderbuffers(1, &name);

        AssertOpenGLNoError_();
		}
	return(self);
	}

- (id)initWithInternalFormat:(GLenum)inInternalFormat size:(SIntSize)inSize;
    {
    if ((self = [self init]) != NULL)
        {
        [self storage:inInternalFormat size:inSize];
        }
    return self;
    }

- (void)dealloc
    {
    if (glIsRenderbuffer(name))
        {
        glDeleteRenderbuffers(1, &name);
        name = 0;
        }
    }

- (SIntSize)size
    {
    [self bind];
    
    SIntSize theSize;
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &theSize.width);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &theSize.height);

    AssertOpenGLNoError_();

    return(theSize);
    }

- (void)bind
    {
    glBindRenderbuffer(GL_RENDERBUFFER, self.name);
    }

- (void)storage:(GLenum)inIntermalFormat size:(SIntSize)inSize;
    {
    [self bind];
    glRenderbufferStorage(GL_RENDERBUFFER, inIntermalFormat, inSize.width, inSize.height);

    AssertOpenGLNoError_();
    }

#if TARGET_OS_IPHONE == 1
- (void)storageFromContext:(EAGLContext *)inContext drawable:(id <EAGLDrawable>)inDrawable
    {
    [self bind];
    
    [inContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:inDrawable];

    AssertOpenGLNoError_();
    }
#endif

@end

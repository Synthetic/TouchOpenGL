//
//  CFrameBuffer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 02/15/11.
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

#import "CFrameBuffer.h"

#import "CRenderBuffer.h"

#import "CTexture.h"

@implementation CFrameBuffer

@synthesize name;

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        glGenFramebuffers(1, &name);

        AssertOpenGLNoError_();
		}
	return(self);
	}

- (void)dealloc
    {
    if (glIsFramebuffer(name))
        {
        glDeleteFramebuffers(1, &name);
        name = 0;
        }
    }

- (BOOL)isComplete:(GLenum)inTarget
    {
    NSAssert(glIsFramebuffer(name), @"name is not a framebuffer");
    GLenum theStatus = glCheckFramebufferStatus(inTarget);
    return(theStatus == GL_FRAMEBUFFER_COMPLETE);
    }

- (void)bind:(GLenum)inTarget
    {
    glBindFramebuffer(inTarget, self.name);
    }

- (void)attachRenderBuffer:(CRenderBuffer *)inRenderBuffer attachment:(GLenum)inAttachment
    {
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, inAttachment, GL_RENDERBUFFER, inRenderBuffer.name);
    AssertOpenGLNoError_();
    }
    
- (void)attachTexture:(CTexture *)inTexture attachment:(GLenum)inAttachment
    {
    glFramebufferTexture2D(GL_FRAMEBUFFER, inAttachment, GL_TEXTURE_2D, inTexture.name, 0);
    AssertOpenGLNoError_();
    }

@end

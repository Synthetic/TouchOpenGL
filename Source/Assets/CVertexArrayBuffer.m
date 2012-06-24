//
//  CVertexArrayBuffer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/24/11.
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

#import "CVertexArrayBuffer.h"

#import "OpenGLIncludes.h"

@implementation CVertexArrayBuffer

@synthesize name;
@synthesize populated;

- (void)invalidate
    {
	if (self.named == YES)
		{
        AssertOpenGLNoError_();
        #if TARGET_OS_IPHONE
            glDeleteVertexArraysOES(1, &name);
        #else
            glDeleteVertexArrays(1, &name);
        #endif /* TARGET_OS_IPHONE */
        AssertOpenGLNoError_();
        }

    [super invalidate];
    }

- (GLuint)name
    {
    if (name == 0)
        {
        AssertOpenGLNoError_();
        #if TARGET_OS_IPHONE
            glGenVertexArraysOES(1, &name);
        #else
            glGenVertexArrays(1, &name);
        #endif /* TARGET_OS_IPHONE */
        AssertOpenGLNoError_();
        }
    return(name);
    }

- (void)bind
    {
    AssertOpenGLNoError_();
    #if TARGET_OS_IPHONE
        glBindVertexArrayOES(self.name);
    #else
        glBindVertexArray(self.name);
    #endif /* TARGET_OS_IPHONE */
    AssertOpenGLNoError_();
    }

- (void)unbind
    {
    AssertOpenGLNoError_();
    #if TARGET_OS_IPHONE
        glBindVertexArrayOES(0);
    #else
        glBindVertexArray(0);
    #endif /* TARGET_OS_IPHONE */
    AssertOpenGLNoError_();
    }

@end

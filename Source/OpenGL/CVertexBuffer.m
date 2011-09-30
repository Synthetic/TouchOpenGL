//
//  CVertexArray.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/05/10.
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

#import "CVertexBuffer.h"

#import "OpenGLTypes.h"
#import "CVertexBufferReference.h"

@implementation CVertexBuffer

@synthesize target;
@synthesize usage;
@synthesize data;
@synthesize name;

- (id)initWithTarget:(GLenum)inTarget usage:(GLenum)inUsage data:(NSData *)inData;
    {
	NSAssert(inTarget != 0, @"Invalid target.");
	NSAssert(inUsage != 0, @"Invalid usage.");
	NSAssert(inData != NULL, @"Invalid data.");
	
    if ((self = [super init]) != NULL)
        {
        target = inTarget;
        usage = inUsage;
        data = [inData retain];
        }
    return(self);
    }
    
- (id)initWithTarget:(GLenum)inTarget usage:(GLenum)inUsage bytes:(void *)inBytes length:(size_t)inLength;
    {
    if ((self = [self initWithTarget:inTarget usage:inUsage data:[NSData dataWithBytes:inBytes length:inLength]]) != NULL)
        {
        }
    return(self);
    }
    
- (void)dealloc
    {
    if (glIsBuffer(name))
        {
        glDeleteBuffers(1, &name);
        name = 0;
        }
    
    [data release];
    data = NULL;
    //
    [super dealloc];
    }
    
- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (target: %@, usage: %@, data: %d bytes @ %p, name: %d)", [super description], NSStringFromGLenum(self.target), NSStringFromGLenum(self.usage), self.data.length, self.data.bytes, name]);
    }

- (GLuint)name
    {
    if (name == 0)
        {
        AssertOpenGLNoError_();
        
        GLuint theName;
        glGenBuffers(1, &theName);
        AssertOpenGLNoError_();

        glBindBuffer(self.target, theName);
        glBufferData(self.target, [self.data length], NULL, self.usage);
        glBufferSubData(self.target, 0, [self.data length], [self.data bytes]);

        AssertOpenGLNoError_();
        
        GLenum theError = glGetError();
        if (theError != GL_NO_ERROR)
            {
            NSLog(@"Vertex Buffer Error: %x", theError);
            NSAssert(NO, @"Vertex Buffer Error");
            }

        // TODO: either skip this - or save/restore previous value
        glBindBuffer(self.target, 0);
        
        name = theName;
//        
//        [data release];
//        data = NULL;
        AssertOpenGLNoError_();
        }
    return(name);
    }

@end

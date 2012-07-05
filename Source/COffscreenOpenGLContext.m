//
//  COffscreenOpenGLContext.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 6/28/12.
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

#import "COffscreenOpenGLContext.h"

#import "CFrameBuffer.h"
#import "CRenderBuffer.h"

@interface COffscreenOpenGLContext ()
@property (readwrite, nonatomic, strong) CFrameBuffer *frameBuffer;
@property (readwrite, nonatomic, strong) CRenderBuffer *colorBuffer;
@end

#pragma mark -

@implementation COffscreenOpenGLContext

- (id)initWithSize:(SIntSize)inSize
    {
    if ((self = [super init]) != NULL)
        {
        [self use];

        AssertOpenGLNoError_();

        _size = inSize;
        _frameBuffer = [[CFrameBuffer alloc] initWithTarget:GL_FRAMEBUFFER];
        [_frameBuffer bind];

        AssertOpenGLNoError_();

        _colorBuffer = [[CRenderBuffer alloc] initWithInternalFormat:GL_RGBA size:_size];
        [_colorBuffer bind];
        [_frameBuffer attachObject:_colorBuffer attachment:GL_COLOR_ATTACHMENT0];

        glClearColor(0.0, 0.0, 0.0, 1.0);
        glViewport(0, 0, _size.width, _size.height);
        glClear(GL_COLOR_BUFFER_BIT);

        AssertOpenGLNoError_();
        }
    return self;
    }

- (void)use
    {
    [super use];

	AssertOpenGLNoError_();

    [self.frameBuffer bind];

	AssertOpenGLNoError_();

    [self.colorBuffer bind];

	AssertOpenGLNoError_();
    }

@end
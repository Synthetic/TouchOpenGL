//
//  COffscreenOpenGLContext.m
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 6/28/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

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

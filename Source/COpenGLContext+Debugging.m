//
//  COpenGLContext+Debugging.m
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 6/28/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import "COpenGLContext+Debugging.h"

#import "OpenGLTypes.h"

@implementation COpenGLContext (Debugging)

- (void)dump
    {
	AssertOpenGLNoError_();

    GLint N;
    glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &N);
    NSLog(@"GL_ARRAY_BUFFER_BINDING: %d", N);

	AssertOpenGLNoError_();
    }

@end

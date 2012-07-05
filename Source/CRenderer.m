//
//  ES2Renderer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/05/10.
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

#import "CRenderer.h"

#import <QuartzCore/QuartzCore.h>

#import "OpenGLIncludes.h"

@interface CRenderer ()
@property (readwrite, nonatomic, assign) BOOL needsSetup;
@property (readwrite, nonatomic, assign) CFAbsoluteTime startTime;

@property (readwrite, nonatomic, assign) double frameRate;
@end

#pragma mark -

@implementation CRenderer

@synthesize size = _size;
@synthesize projectionTransform = _projectionTransform;
@synthesize context = _context;
@synthesize frameRate = _frameRate;

@synthesize needsSetup = _needsSetup;
@synthesize startTime = _startTime;

- (id)init
    {
    if ((self = [super init]))
        {
        _projectionTransform = Matrix4Identity;
        _needsSetup = YES;
        }
    return self;
    }

- (id)copyWithZone:(NSZone *)zone;
	{
	CRenderer *theCopy = [[[self class] alloc] init];
	theCopy.projectionTransform = self.projectionTransform;
	return(theCopy);
	}

#pragma mark -

- (void)setup
    {
	AssertOpenGLValidContext_();

	AssertOpenGLNoError_();

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glEnable(GL_DEPTH_TEST);

    glDepthFunc(GL_LEQUAL);

    self.needsSetup = NO;
	
	AssertOpenGLNoError_();
    }

- (void)prerender
    {
	AssertOpenGLNoError_();

    if (self.needsSetup == YES)
        {
        [self setup];
        }

	AssertOpenGLNoError_();
    }

- (void)render
    {
    }

- (void)postrender
    {
    }

- (void)setNeedsSetup
    {
    self.needsSetup = YES;
    }

@end

#pragma mark -

@implementation COpenGLContext (Renderer)

- (void)render:(CRenderer *)inRenderer
    {
	[self use];

	AssertOpenGLNoError_();

    if (inRenderer.context == NULL)
        {
        inRenderer.context = self;
        }
    
    AssertOpenGLNoError_();

//		if (self.setup == NO)
//			{
        [inRenderer setup];
        //
//			self.setup = YES;
//			}


    AssertOpenGLNoError_();

    [inRenderer prerender];

    AssertOpenGLNoError_();

    [inRenderer render];

    AssertOpenGLNoError_();

    [inRenderer postrender];

    AssertOpenGLNoError_();

	glFlush();
    }

@end


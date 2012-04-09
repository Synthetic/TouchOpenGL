//
//  ES2Renderer.m
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

#import "CSceneRenderer.h"

#import <QuartzCore/QuartzCore.h>

@interface CSceneRenderer ()
@property (readwrite, nonatomic, assign) BOOL needsSetup;
@property (readwrite, nonatomic, assign) NSUInteger frameCount;
@property (readwrite, nonatomic, assign) CFAbsoluteTime startTime;

@property (readwrite, nonatomic, assign) double frameRate;
@end

#pragma mark -

@implementation CSceneRenderer

@synthesize size = _size;
@synthesize clearColor = _clearColor;
@synthesize projectionTransform = _projectionTransform;
@synthesize frameRate = _frameRate;

@synthesize needsSetup = _needsSetup;
@synthesize frameCount = _frameCount;
@synthesize startTime = _startTime;

- (id)init
    {
    if ((self = [super init]))
        {
        _clearColor = (Color4f){ 0.5f, 0.5f, 0.5f, 1.0f };
        _projectionTransform = Matrix4Identity;
        _needsSetup = YES;
        }
    return self;
    }

- (id)copyWithZone:(NSZone *)zone;
	{
	CSceneRenderer *theCopy = [[[self class] alloc] init];
	theCopy.clearColor = self.clearColor;
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
    #if TARGET_OS_IPHONE == 1
    glClearDepthf(1.0f);
    #else
    glClearDepth(1.0f);
    #endif

    glDepthFunc(GL_LEQUAL);

    glClearColor(_clearColor.r, _clearColor.g, _clearColor.b, _clearColor.a);

    self.needsSetup = NO;
	
	AssertOpenGLNoError_();
    }

- (void)clear
    {
	AssertOpenGLValidContext_();

	AssertOpenGLNoError_();

    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);

	AssertOpenGLNoError_();
    }

- (void)prerender
    {
    if (self.needsSetup == YES)
        {
        [self setup];
        }

    [self clear];
    }

- (void)render
    {
    }

- (void)postrender
    {
	const CFAbsoluteTime theTime = CFAbsoluteTimeGetCurrent();
	if (_frameCount++ == 0)
		{
//		NSLog(@"START");
		_startTime = theTime;
		}
	else
		{
//		NSLog(@"%f %f", theTime, _startTime);
		self.frameRate = 1.0 / ((theTime - _startTime) / (double)_frameCount);
		}
    }

- (void)setNeedsSetup
    {
    self.needsSetup = YES;
    }

@end

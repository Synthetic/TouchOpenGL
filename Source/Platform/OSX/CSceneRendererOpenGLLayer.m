//
//  CRendererOpenGLLayer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 01/31/11.
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

#import "CSceneRendererOpenGLLayer.h"

#import "CRenderer.h"
#import "COpenGLContext.h"

@interface CSceneRendererOpenGLLayer ()
@property (readwrite, nonatomic, assign) NSUInteger frameCount;
@property (readwrite, nonatomic, assign) BOOL setup;
@property (readwrite, nonatomic, strong) COpenGLContext *context;
@end

#pragma mark -

@implementation CSceneRendererOpenGLLayer

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        self.asynchronous = YES;
        
        _renderer = [[CRenderer alloc] init];
        _frameCount = 0;
        }
    return(self);
    }

- (CGLPixelFormatObj)copyCGLPixelFormatForDisplayMask:(uint32_t)mask
    {
    CGLPixelFormatAttribute thePixelFormatAttributes[] = {
//		kCGLPFAOpenGLProfile, kCGLOGLPVersion_Legacy,
		kCGLPFAOpenGLProfile, kCGLOGLPVersion_3_2_Core,
        kCGLPFADisplayMask, mask,
        kCGLPFAAccelerated,
        kCGLPFAColorSize, 8,
        kCGLPFAAlphaSize, 8,
        kCGLPFADepthSize, 16,
        kCGLPFANoRecovery,
        kCGLPFAMultisample,
        kCGLPFASupersample,
        kCGLPFASampleAlpha,
        0
        };
    CGLPixelFormatObj thePixelFormatObject = NULL;
    GLint theNumberOfPixelFormats = 0;
    CGLChoosePixelFormat(thePixelFormatAttributes, &thePixelFormatObject, &theNumberOfPixelFormats);
    if (thePixelFormatObject == NULL)
        {
        NSLog(@"Error: Could not choose pixel format!");
        }
    return(thePixelFormatObject);
    }

- (void)drawInCGLContext:(CGLContextObj)ctx pixelFormat:(CGLPixelFormatObj)pf forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts
    {
    self.frameCount++;

	if (self.context == NULL)
		{
		self.context = [[COpenGLContext alloc] initWithNativeContext:ctx];
		}

	if (self.renderer == NULL)
		{
		return;
		}
		
	if (self.renderer.context == NULL)
		{
		NSParameterAssert(self.context != NULL);
		self.renderer.context = self.context;
		}

	NSParameterAssert(self.context.nativeContext == ctx);

    AssertOpenGLNoError_();

	[self.context use];

    AssertOpenGLNoError_();

    if (self.setup == NO)
        {
		[self.renderer setup];
        self.setup = YES;
        }

    AssertOpenGLNoError_();

    AssertOpenGLNoError_();

    [self.renderer prerender];

    AssertOpenGLNoError_();

    [self.renderer render];

    AssertOpenGLNoError_();

    [self.renderer postrender];

//    [super drawInCGLContext:ctx pixelFormat:pf forLayerTime:t displayTime:ts];

    AssertOpenGLNoError_();
    }

@end

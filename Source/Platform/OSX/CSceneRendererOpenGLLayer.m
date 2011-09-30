//
//  CRendererOpenGLLayer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 01/31/11.
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

#import "CSceneRendererOpenGLLayer.h"

#import "CSceneRenderer.h"

@interface CSceneRendererOpenGLLayer ()
@property (readwrite, nonatomic, assign) BOOL setup;
@end

#pragma mark -

@implementation CSceneRendererOpenGLLayer

@synthesize renderer;

@synthesize setup;

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        self.asynchronous = YES;
        
        renderer = [[CSceneRenderer alloc] init];
        }
    return(self);
    }

- (CGLPixelFormatObj)copyCGLPixelFormatForDisplayMask:(uint32_t)mask
    {
    CGLPixelFormatAttribute thePixelFormatAttributes[] = {
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
    CGLSetCurrentContext(ctx);
    
    if (self.setup == NO)
        {
//        self.renderer.size = (SIntSize){ .width = self.bounds.size.width, .height = self.bounds.size.height };

        self.setup = YES;
        }

    [self.renderer prerender];
    [self.renderer render];
    [self.renderer postrender];

    [super drawInCGLContext:ctx pixelFormat:pf forLayerTime:t displayTime:ts];
    }

@end

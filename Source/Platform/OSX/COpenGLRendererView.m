//
//  COpenGLRendererView.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 3/23/12.
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

#import "COpenGLRendererView.h"

#import "CRenderer.h"
#import "COpenGLContext.h"
#import <CoreVideo/CoreVideo.h>

static CVReturn MyCVDisplayLinkOutputCallback(CVDisplayLinkRef displayLink,  const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext);

@interface COpenGLRendererView ()
@property (readwrite, nonatomic, strong) NSArray *renderers;
@property (readwrite, nonatomic, assign) BOOL setup;
@property (readwrite, nonatomic, assign) CVDisplayLinkRef displayLink;
@end

#pragma mark -

@implementation COpenGLRendererView

- (id)initWithCoder:(NSCoder *)inCoder
    {
    if ((self = [super initWithCoder:inCoder]) != NULL)
        {
        _renderers = [NSArray array];

        NSOpenGLPixelFormatAttribute pixelFormatAttributes[] = {
            NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
            0
            };
        NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
        NSOpenGLContext *theOpenGLContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
        self.openGLContext = theOpenGLContext;

		void *theNativeContext = self.openGLContext.CGLContextObj;
		_context = [[COpenGLContext alloc] initWithNativeContext:theNativeContext];

		CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
		CVDisplayLinkSetOutputCallback(_displayLink, MyCVDisplayLinkOutputCallback, (__bridge void *)self);
        }
    return(self);
    }

- (void)dealloc
	{
	if (_displayLink)
		{
		if (CVDisplayLinkIsRunning(_displayLink))
			{
			CVDisplayLinkStop(_displayLink);
			}
		CVDisplayLinkRelease(_displayLink);
		}
	}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
	{
	if (newWindow != NULL)
		{
		CVDisplayLinkStart(_displayLink);
		}
	else
		{
		CVDisplayLinkStop(_displayLink);
		}
	}

- (void)reshape
	{
	[super reshape];
	
	glViewport(0, 0, self.frame.size.width, self.frame.size.height);
	}

- (void)drawRect:(NSRect)dirtyRect
	{
	[super drawRect:dirtyRect];

	NSParameterAssert(self.context != NULL);
	NSParameterAssert(self.context.nativeContext == [[self openGLContext] CGLContextObj]);

	[self.context use];

	AssertOpenGLNoError_();

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    for (CRenderer *theRenderer in self.renderers)
        {
        if (theRenderer.context == NULL)
            {
            theRenderer.context = self.context;
            }
        
        AssertOpenGLNoError_();

        if (self.setup == NO)
            {
            [theRenderer setup];
            //
            self.setup = YES;
            }

        AssertOpenGLNoError_();

        [theRenderer prerender];

        AssertOpenGLNoError_();

        [theRenderer render];

        AssertOpenGLNoError_();

        [theRenderer postrender];

        AssertOpenGLNoError_();
        }

	glFlush();
	}

- (void)addRenderer:(CRenderer *)inRenderer
    {
    self.renderers = [self.renderers arrayByAddingObject:inRenderer];
    }

- (void)removeRenderer:(CRenderer *)inRenderer
    {
    NSMutableArray *theRenderers = [self.renderers mutableCopy];
    [theRenderers removeObject:inRenderer];
    self.renderers = [theRenderers copy];
    }

@end

#pragma mark -

static CVReturn MyCVDisplayLinkOutputCallback(CVDisplayLinkRef displayLink,  const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext)
	{
	@autoreleasepool
		{
		COpenGLRendererView *theView = (__bridge COpenGLRendererView *)displayLinkContext;
		[theView setNeedsDisplay:YES];
		}
	return(kCVReturnSuccess);
	}

//
//  COpenGLRendererView.m
//  GLEffectComposer
//
//  Created by Jonathan Wight on 3/23/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "COpenGLRendererView.h"

#import "CSceneRenderer.h"
#import "COpenGLContext.h"
#import <CoreVideo/CoreVideo.h>

static CVReturn MyCVDisplayLinkOutputCallback(CVDisplayLinkRef displayLink,  const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext);

@interface COpenGLRendererView ()
@property (readwrite, nonatomic, assign) BOOL setup;
@property (readwrite, nonatomic, assign) CVDisplayLinkRef displayLink;
@end

#pragma mark -

@implementation COpenGLRendererView

- (id)initWithCoder:(NSCoder *)inCoder
    {
    if ((self = [super initWithCoder:inCoder]) != NULL)
        {
		NSOpenGLContext *theOpenGLContext = [self openGLContext];
		void *theNativeContext = [theOpenGLContext CGLContextObj];
		_context = [[COpenGLContext alloc] initWithNativeContext:theNativeContext size:(SIntSize){ self.frame.size.width, self.frame.size.height }];

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

	if (self.renderer != NULL)
		{
		if (self.renderer.context == NULL)
			{
			self.renderer.context = self.context;
			}
		
		AssertOpenGLNoError_();

		if (self.setup == NO)
			{
			[self.renderer setup];
			//
			self.setup = YES;
			}

		AssertOpenGLNoError_();

		[self.renderer prerender];

		AssertOpenGLNoError_();

		[self.renderer render];

		AssertOpenGLNoError_();

		[self.renderer postrender];

		AssertOpenGLNoError_();
		}

	glFlush();
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

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

- (void)drawRect:(NSRect)dirtyRect
	{
	NSParameterAssert(self.context != NULL);

	if (self.renderer == NULL)
		{
		return;
		}
		
	if (self.renderer.context == NULL)
		{
		NSParameterAssert(self.context != NULL);
		self.renderer.context = self.context;
		}

	[self.context use];
    
    if (self.setup == NO)
        {
		[self.renderer setup];
		//
        self.setup = YES;
        }

    [self.renderer prerender];
    [self.renderer render];
    [self.renderer postrender];
	}

- (void)reshape
	{
	[super reshape];
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

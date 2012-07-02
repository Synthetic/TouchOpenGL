//
//  EAGLView.m
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

#import "CRendererView.h"

#import "CSceneRenderer.h"
#import "CFrameBuffer.h"
#import "CRenderBuffer.h"
#import "UIColor_OpenGLExtensions.h"
#import "COpenGLContext.h"

@interface CRendererView ()
@property (readonly, nonatomic, assign) CADisplayLink *displayLink;

@property (readwrite, nonatomic, assign) BOOL animating;
@property (readonly, nonatomic, strong) CAEAGLLayer *EAGLLayer;

- (void)setup;
- (void)tick:(id)inSender;
- (void)startAnimation:(id)inParameter;
- (void)stopAnimation:(id)inParameter;
@end

#pragma mark -

@implementation CRendererView

@synthesize context = _context;
@synthesize animationFrameInterval = _animationFrameInterval;
@synthesize renderer = _renderer;
@synthesize displayLink = _displayLink;
@synthesize animating = _animating;
@synthesize EAGLLayer = _EAGLLayer;

+ (Class)layerClass
    {
    return([CAEAGLLayer class]);
    }

#pragma mark -

- (id)initWithFrame:(CGRect)inFrame;
    {    
    if ((self = [super initWithFrame:inFrame]))
        {
        _animationFrameInterval = 1.0;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimation:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];

		[self setup];
        }

    return self;
    }
    
- (id)initWithCoder:(NSCoder *)inDecoder
    {    
    if ((self = [super initWithCoder:inDecoder]) != NULL)
        {
        _animationFrameInterval = 1.0;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimation:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
		
		[self setup];
        }

    return self;
    }

- (void)dealloc
    {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    
	if (_context.isActive == YES)
		{
		[_context unuse];
		}
    }

#pragma mark -

//- (void)layoutSubviews
//    {
//    [super layoutSubviews];
//    //
//    if (self.renderer != NULL)
//        {
//        [self render];
//        }
//    }

- (void)removeFromSuperview
    {
    [self stopAnimation];

    [super removeFromSuperview];
    }

- (void)willMoveToWindow:(UIWindow *)newWindow
    {
    [super willMoveToWindow:newWindow];
    //
    if (newWindow == NULL)
        {
        [self stopAnimation];
        }
    }

- (void)setFrame:(CGRect)inFrame
    {
    [super setFrame:inFrame];
    
    self.renderer.size = inFrame.size;
    }

#pragma mark -

- (void)setRenderer:(CSceneRenderer *)inRenderer;
    {
    if (_renderer != inRenderer)
        {
        _renderer = inRenderer;
        _renderer.size = self.frame.size;
		_renderer.context = self.context;
        //
        if (_renderer != NULL)
            {
            [self startAnimation];
            }
        }
    }

- (CAEAGLLayer *)EAGLLayer
    {
    return((CAEAGLLayer *)self.layer);
    }

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
    {
	if (_animationFrameInterval != frameInterval)
		{
		// Frame interval defines how many display frames must pass between each time the display link fires. The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
		if (frameInterval >= 1)
			{
			_animationFrameInterval = frameInterval;
			if (self.animating)
				{
				[self stopAnimation];
				[self startAnimation];
				}
			}
		}
    }

- (void)startAnimation
    {
    if (!self.animating)
        {
        self.animating = YES;

        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [_displayLink setFrameInterval:self.animationFrameInterval];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
    }

- (void)stopAnimation
    {
    if (self.animating)
        {
        self.animating = NO;

        [_displayLink invalidate];
        _displayLink = NULL;
        }
    }
   
- (void)render
    {
    NSAssert(self.renderer != NULL, @"No renderer");

	[self.context use];

	AssertOpenGLValidContext_();

	[self.context.frameBuffer bind];
	[self.context.colorBuffer bind];

	self.renderer.context = self.context;

	const SIntSize theSize = { .width = self.bounds.size.width, .height = self.bounds.size.height };

	glViewport(0, 0, theSize.width, theSize.height);

    AssertOpenGLNoError_();


#warning TODO
//    if (self.multisampleAntialiasing == NO)
//        {
//        [self.frameBuffer bind];
//        }
//    else
//        {
//        [self.sampleFrameBuffer bind];
//        }
    
    [self.renderer prerender];
    [self.renderer render];
    [self.renderer postrender];

    AssertOpenGLNoError_();

	[self.context present];

    AssertOpenGLNoError_();
    }
    
#pragma mark -

- (void)setup
    {
    self.EAGLLayer.opaque = TRUE;
    self.EAGLLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
        nil];

    if (_context == NULL)
        {
        self.context = [[COpenGLContext alloc] initWithDrawable:self.EAGLLayer];
        }

	[self.context use];

    AssertOpenGLValidContext_();
    }

- (void)tick:(id)inSender
    {
    #pragma unused (inSender)
    
    if (self.animating)
        {
        [self render];
        }
    }
    
- (void)startAnimation:(id)inParameter
    {
    #pragma unused (inParameter)
    [self startAnimation];
    }
    
- (void)stopAnimation:(id)inParameter
    {
    #pragma unused (inParameter)
    [self stopAnimation];
    }

@end

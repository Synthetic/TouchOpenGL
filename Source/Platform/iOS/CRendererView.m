//
//  EAGLView.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CRendererView.h"

#import "CSceneRenderer.h"
#import "CFrameBuffer.h"
#import "CRenderBuffer.h"

@interface CRendererView ()
@property (readonly, nonatomic, assign) CADisplayLink *displayLink;

@property (readwrite, nonatomic, assign) BOOL animating;
@property (readonly, nonatomic, retain) CAEAGLLayer *EAGLLayer;

- (void)setup;
- (void)tick:(id)inSender;
- (void)startAnimation:(id)inParameter;
- (void)stopAnimation:(id)inParameter;
@end

#pragma mark -

@implementation CRendererView

@synthesize displayLink;
@synthesize backingSize;
@synthesize context;
@synthesize animationFrameInterval;
@synthesize multisampleAntialiasing;
@synthesize renderer;
@synthesize animating;
@synthesize frameBuffer;
@synthesize colorRenderBuffer;
@synthesize depthRenderBuffer;
@synthesize sampleFrameBuffer;
@synthesize sampleColorRenderBuffer;
@synthesize sampleDepthRenderBuffer;

+ (Class)layerClass
    {
    return [CAEAGLLayer class];
    }

#pragma mark -

- (id)initWithFrame:(CGRect)inFrame;
    {    
    if ((self = [super initWithFrame:inFrame]))
        {
        animationFrameInterval = 1.0;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimation:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
        
        self.renderer = [[CSceneRenderer alloc] init];
        }

    return self;
    }
    
- (id)initWithCoder:(NSCoder *)inDecoder
    {    
    if ((self = [super initWithCoder:inDecoder]) != NULL)
        {
        animationFrameInterval = 1.0;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimation:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];

        self.renderer = [[CSceneRenderer alloc] init];
        }

    return self;
    }

- (void)dealloc
    {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    
    if ([EAGLContext currentContext] == context)
        {
        [EAGLContext setCurrentContext:nil];
        }
    }

#pragma mark -

- (void)layoutSubviews
    {
    [super layoutSubviews];
    //
    if (self.renderer != NULL)
        {
        [self render];
        }
    }

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

#pragma mark -

- (void)setRenderer:(CSceneRenderer *)inRenderer;
    {
    if (renderer != inRenderer)
        {
        renderer = inRenderer;
        //
        if (renderer != NULL)
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
    // Frame interval defines how many display frames must pass between each time the display link fires. The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
    if (frameInterval >= 1)
        {
        animationFrameInterval = frameInterval;
        if (self.animating)
            {
            [self stopAnimation];
            [self startAnimation];
            }
        }
    }

- (void)startAnimation
    {
    if (!self.animating)
        {
        self.animating = YES;

        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [displayLink setFrameInterval:self.animationFrameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
    }

- (void)stopAnimation
    {
    if (self.animating)
        {
        self.animating = NO;

        [displayLink invalidate];
        displayLink = NULL;
        }
    }
    
- (void)render
    {
    NSAssert(self.renderer != NULL, @"No renderer");


    if (self.context == NULL)
        {
        [self setup];
        [self.renderer setup];

        const SIntSize theSize = { .width = self.bounds.size.width, .height = self.bounds.size.height };

        glViewport(0, 0, theSize.width, theSize.height);
        }
        
    if (self.multisampleAntialiasing == NO)
        {
        [self.frameBuffer bind:GL_FRAMEBUFFER];
        }
    else
        {
        [self.sampleFrameBuffer bind:GL_FRAMEBUFFER];
        }
    
    [self.renderer prerender];
    [self.renderer render];
    [self.renderer postrender];

    if (self.multisampleAntialiasing == NO)
        {
        [self.colorRenderBuffer bind];

        // Discard frame buffers for extra performance: see http://www.khronos.org/registry/gles/extensions/EXT/EXT_discard_framebuffer.txt
        GLenum theAttachments[] = { GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT };
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, theAttachments);

        [self.context presentRenderbuffer:GL_RENDERBUFFER];
        }
    else
        {
        glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, self.sampleFrameBuffer.name);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, self.frameBuffer.name);
        // Call a resolve to combine buffers
        glResolveMultisampleFramebufferAPPLE();
        // Present final image to screen

        // Discard frame buffers for extra performance: see http://www.khronos.org/registry/gles/extensions/EXT/EXT_discard_framebuffer.txt
        GLenum theAttachments[] = { GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT };
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, theAttachments);

        glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderBuffer.name);
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
        }

    AssertOpenGLNoError_();
    }
    
#pragma mark -

- (void)setup
    {
    self.multisampleAntialiasing = NO;
    self.EAGLLayer.opaque = TRUE;
    self.EAGLLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
        nil];

    if (context == NULL)
        {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        }

    [EAGLContext setCurrentContext:self.context];

    AssertOpenGLValidContext_();

    // Create frame buffer
    self.frameBuffer = [[CFrameBuffer alloc] init];
    [self.frameBuffer bind:GL_FRAMEBUFFER];
    
    // Create a color render buffer - and configure it with current context & drawable
    self.colorRenderBuffer = [[CRenderBuffer alloc] init];
    [self.colorRenderBuffer storageFromContext:self.context drawable:self.EAGLLayer];

    // Attach color buffer to frame buffer
    [self.frameBuffer attachRenderBuffer:self.colorRenderBuffer attachment:GL_COLOR_ATTACHMENT0];
    
    // Get the size of the color buffer (we'll be using this a lot)
    self.backingSize = self.colorRenderBuffer.size;
  
    // Create a depth buffer - and configure it to the size of the color buffer.
    self.depthRenderBuffer = [[CRenderBuffer alloc] init];
    [self.depthRenderBuffer storage:GL_DEPTH_COMPONENT16 size:self.backingSize];

    // Attach depth buffer to the frame buffer
    [self.frameBuffer attachRenderBuffer:self.depthRenderBuffer attachment:GL_DEPTH_ATTACHMENT];

    // Make sure the frame buffer has a complete set of render buffers.

	if ([self.frameBuffer isComplete:GL_FRAMEBUFFER] == NO)
        {
		NSLog(@"createFramebuffer failed %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        }

    // #########################################################################

    if (self.multisampleAntialiasing == YES)
        {
        self.sampleFrameBuffer = [[CFrameBuffer alloc] init];
        [self.sampleFrameBuffer bind:GL_FRAMEBUFFER];
        
        self.sampleColorRenderBuffer = [[CRenderBuffer alloc] init];
        [self.sampleColorRenderBuffer bind];
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, self.backingSize.width, self.backingSize.height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.sampleColorRenderBuffer.name);

        self.sampleDepthRenderBuffer = [[CRenderBuffer alloc] init];
        [self.sampleDepthRenderBuffer bind];
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, self.backingSize.width, self.backingSize.height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, self.sampleDepthRenderBuffer.name);


        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            {
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
            }
        }
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

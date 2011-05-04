//
//  ES2Renderer.m
//  Racing Genes
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CRenderer.h"

#import <QuartzCore/QuartzCore.h>

@interface CRenderer ()
@property (readwrite, nonatomic, assign) BOOL needsSetup;
@end

#pragma mark -

@implementation CRenderer

@synthesize size = _size;
@synthesize projectionTransform;

@synthesize needsSetup;

- (id)init
    {
    if ((self = [super init]))
        {
        projectionTransform = Matrix4Identity;
        needsSetup = YES;
        }

    return self;
    }

- (void)dealloc
    {
    //
    [super dealloc];
    }

#pragma mark -

- (void)setup
    {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glEnable(GL_DEPTH_TEST);
    #if TARGET_OS_IPHONE == 1
    glClearDepthf(1.0f);
    #else
    glClearDepth(1.0f);
    #endif
    
    glDepthFunc(GL_LEQUAL);

    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    
    self.needsSetup = NO;
    }

- (void)clear
    {
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
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
    }


- (void)setNeedsSetup
    {
    self.needsSetup = YES;
    }
    
@end

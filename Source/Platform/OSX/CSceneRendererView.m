//
//  CRendererView2.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 01/31/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CSceneRendererView.h"

#import "CSceneRendererOpenGLLayer.h"

@interface CSceneRendererView ()
@end

#pragma mark -

@implementation CSceneRendererView

- (id)initWithCoder:(NSCoder*)coder
    {    
    if ((self = [super initWithCoder:coder]) != NULL)
        {
        self.wantsLayer = YES;
        self.layer = [[CSceneRendererOpenGLLayer alloc] init];
        }

    return self;
    }

- (id)initWithFrame:(CGRect)inFrame;
    {    
    if ((self = [super initWithFrame:inFrame]) != NULL)
        {
        self.wantsLayer = YES;
        self.layer = [[CSceneRendererOpenGLLayer alloc] init];
        }

    return self;
    }
    
#pragma mark -

- (CRenderer *)renderer
    {
    return(self.rendererLayer.renderer);
    }

- (void)setRenderer:(CRenderer *)inRenderer
    {
    self.rendererLayer.renderer = inRenderer;
    }

#pragma mark -

- (CSceneRendererOpenGLLayer *)rendererLayer
    {
    return((CSceneRendererOpenGLLayer *)self.layer);
    }

@end

//
//  CMyOpenRendererView.m
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 7/5/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import "CMyOpenGLRendererView.h"

#import "CFrameCounter.h"

@implementation CMyOpenGLRendererView

@synthesize frameCounter = _frameCounter;

- (CFrameCounter *)frameCounter
    {
    if (_frameCounter == NULL)
        {
        _frameCounter = [[CFrameCounter alloc] init];
        }
    return(_frameCounter);
    }

- (void)drawRect:(NSRect)inRect
    {
    [super drawRect:inRect];

    [self.frameCounter incrementFrameCount];
    }

@end

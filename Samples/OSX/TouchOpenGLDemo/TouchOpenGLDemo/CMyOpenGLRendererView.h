//
//  CMyOpenRendererView.h
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 7/5/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import "COpenGLRendererView.h"

@class CFrameCounter;

@interface CMyOpenGLRendererView : COpenGLRendererView

@property (readonly, nonatomic, strong) CFrameCounter *frameCounter;

@end

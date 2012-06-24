//
//  COpenGLRendererView.h
//  GLEffectComposer
//
//  Created by Jonathan Wight on 3/23/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CRenderer;
@class COpenGLContext;

@interface COpenGLRendererView : NSOpenGLView

@property (readwrite, nonatomic, strong) CRenderer *renderer;
@property (readwrite, nonatomic, strong) COpenGLContext *context;

@end

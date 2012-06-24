//
//  CRendererView2.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 01/31/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CSceneRendererOpenGLLayer;
@class CRenderer;

@interface CSceneRendererView : NSView

@property (readonly, nonatomic, strong) CSceneRendererOpenGLLayer *rendererLayer;
@property (readwrite, nonatomic, strong) CRenderer *renderer;

@end

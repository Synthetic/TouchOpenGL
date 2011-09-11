//
//  CSceneRenderer_Extensions.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/17/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CSceneRenderer.h"

#import "OpenGLTypes.h"

@class COpenGLAssetLibrary;

@interface CSceneRenderer (CSceneRenderer_Extensions)

@property (readonly, nonatomic, retain) COpenGLAssetLibrary *library;

- (void)drawAxes:(Matrix4)inModelTransform length:(GLfloat)inLength;
- (void)drawBoundingBox:(Matrix4)inModelTransform v1:(Vector3)inV1 v2:(Vector3)inV2;
- (void)drawBackgroundGradient;

- (CGImageRef)renderIntoImage:(SIntSize)inSize;

@end

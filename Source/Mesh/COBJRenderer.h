//
//  COBJRenderer.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/16/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CRenderer.h"

#import "OpenGLTypes.h"

@class CCamera;
@class CLight;
@class CMaterial;
@class CMesh;

@interface COBJRenderer : CRenderer {
    GLfloat *_depthValues;
}

@property (readwrite, nonatomic, strong) CMesh *mesh;
@property (readwrite, nonatomic, strong) CCamera *camera;
@property (readwrite, nonatomic, strong) CLight *light;
@property (readwrite, nonatomic, strong) CMaterial *defaultMaterial;
@property (readwrite, nonatomic, assign) Matrix4 modelTransform;
@property (readwrite, nonatomic, strong) NSString *defaultProgramName;

- (float)depthAtPoint:(CGPoint)point;

@end

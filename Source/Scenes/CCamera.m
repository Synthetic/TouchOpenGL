//
//  CCamera.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/29/11.
//  Copyright 2011 Inkling. All rights reserved.
//

#import "CCamera.h"

@interface CCamera ()
- (void)update;
@end

#pragma mark -

@implementation CCamera

@synthesize position;
@synthesize xSize;
@synthesize ySize;
@synthesize zSize;
@synthesize transform;

- (void)setXSize:(GLfloat)inXSize
    {
    xSize = inXSize;
    //
    [self update];
    }

- (void)setYSize:(GLfloat)inYSize
    {
    ySize = inYSize;
    //
    [self update];
    }

- (void)setZSize:(GLfloat)inZSize
    {
    zSize = inZSize;
    //
    [self update];
    }

- (void)update
    {
#if USE_PERSPECTIVE
    Vector4 theCameraVector = self.position;
    Matrix4 theCameraTransform = Matrix4MakeTranslation(theCameraVector.x, theCameraVector.y, theCameraVector.z);
    Matrix4 theProjectionTransform = Matrix4Perspective(90, theAspectRatio, 0.1, 100);
    self.transform = Matrix4Concat(theCameraTransform, theProjectionTransform);
#else
    self.transform = Matrix4Ortho(-self.xSize, self.xSize, -self.ySize, self.ySize, -self.zSize, self.zSize);
#endif
    }

@end

//
//  CCamera.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/29/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Jonathan Wight.

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

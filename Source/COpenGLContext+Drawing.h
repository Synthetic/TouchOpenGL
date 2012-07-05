//
//  COpenGLContext+Drawing.h
//  VideoFilterToy_OSX
//
//  Created by Jonathan Wight on 3/12/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "COpenGLContext.h"

#import "Matrix.h"

@interface COpenGLContext (Drawing)

- (void)strokeRect:(CGRect)inRect color:(Color4f)inColor;
- (void)strokeRect:(CGRect)inRect color:(Color4f)inColor transform:(Matrix4f)inTransform;

@end

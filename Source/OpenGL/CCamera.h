//
//  CCamera.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/29/11.
//  Copyright 2011 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpenGLTypes.h"
#import "Matrix.h"

@interface CCamera : NSObject {
    
}

@property (readwrite, nonatomic, assign) Vector4 position;
@property (readwrite, nonatomic, assign) GLfloat xSize;
@property (readwrite, nonatomic, assign) GLfloat ySize;
@property (readwrite, nonatomic, assign) GLfloat zSize;
@property (readwrite, nonatomic, assign) Matrix4 transform;

@end

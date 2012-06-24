//
//  CBlitProgram.m
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CBlitProgram.h"

#import "OpenGLTypes.h"
#import "OpenGLIncludes.h"
#import "CTexture.h"
#import "CVertexBufferReference.h"

@interface CBlitProgram ()

// Uniforms
@property (readwrite, nonatomic, assign) GLint texture0Uniform;
@property (readwrite, nonatomic, assign) GLint texture0Index;

@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform;

@property (readwrite, nonatomic, assign) GLint projectionViewMatrixUniform;

// Attributes
@end

@implementation CBlitProgram

// Uniforms
@synthesize texture0;
@synthesize texture0Uniform;
@synthesize texture0Index;
@synthesize modelViewMatrix;
@synthesize modelViewMatrixUniform;
@synthesize projectionViewMatrix;
@synthesize projectionViewMatrixUniform;

// Attributes
- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        texture0 = NULL;
        texture0Uniform = -1;
        texture0Index = 0;
        modelViewMatrix = Matrix4Identity;
        modelViewMatrixUniform = -1;
        projectionViewMatrix = Matrix4Identity;
        projectionViewMatrixUniform = -1;

        GLint theIndex = 0;
        }
    return self;
    }

- (void)update
    {
    [super update];
    //
    AssertOpenGLNoError_();

    if (texture0Uniform == -1)
        {
        texture0Uniform = glGetUniformLocation(self.name, "u_texture0");
        }

    [texture0 use:texture0Uniform index:texture0Index];
    texture0Changed = NO;
    AssertOpenGLNoError_();
    if (modelViewMatrixUniform == -1)
        {
        modelViewMatrixUniform = glGetUniformLocation(self.name, "u_modelViewMatrix");
        }

    glUniformMatrix4fv(modelViewMatrixUniform, 1, NO, &modelViewMatrix.m[0][0]);
    modelViewMatrixChanged = NO;
    AssertOpenGLNoError_();
    if (projectionViewMatrixUniform == -1)
        {
        projectionViewMatrixUniform = glGetUniformLocation(self.name, "u_projectionMatrix");
        }

    glUniformMatrix4fv(projectionViewMatrixUniform, 1, NO, &projectionViewMatrix.m[0][0]);
    projectionViewMatrixChanged = NO;
    AssertOpenGLNoError_();

    }

- (void)setTexture0:(CTexture *)inTexture0
    {
    texture0 = inTexture0;
    }

- (void)setModelViewMatrix:(Matrix4)inModelViewMatrix
    {
    modelViewMatrix = inModelViewMatrix;
    }

- (void)setProjectionViewMatrix:(Matrix4)inProjectionViewMatrix
    {
    projectionViewMatrix = inProjectionViewMatrix;
    }



@end

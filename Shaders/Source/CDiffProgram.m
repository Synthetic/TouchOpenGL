//
//  CDiffProgram.m
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CDiffProgram.h"

#import "OpenGLTypes.h"
#import "OpenGLIncludes.h"
#import "CTexture.h"
#import "CVertexBufferReference.h"

@interface CDiffProgram () 

// Uniforms
@property (readwrite, nonatomic, assign) GLint projectionMatrixUniform;
@property (readwrite, nonatomic, assign) BOOL projectionMatrixChanged;

@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform;
@property (readwrite, nonatomic, assign) BOOL modelViewMatrixChanged;

@property (readwrite, nonatomic, assign) GLint texture0Uniform;
@property (readwrite, nonatomic, assign) BOOL texture0Changed;
@property (readwrite, nonatomic, assign) GLint texture0Index;

@property (readwrite, nonatomic, assign) GLint texture1Uniform;
@property (readwrite, nonatomic, assign) BOOL texture1Changed;
@property (readwrite, nonatomic, assign) GLint texture1Index;

// Attributes
@property (readwrite, nonatomic, assign) GLint positionsAttribute;
@property (readwrite, nonatomic, assign) BOOL positionsChanged;

@property (readwrite, nonatomic, assign) GLint texCoordsAttribute;
@property (readwrite, nonatomic, assign) BOOL texCoordsChanged;

@end

@implementation CDiffProgram

// Uniforms
@synthesize projectionMatrix;
@synthesize projectionMatrixUniform;
@synthesize projectionMatrixChanged;

@synthesize modelViewMatrix;
@synthesize modelViewMatrixUniform;
@synthesize modelViewMatrixChanged;

@synthesize texture0;
@synthesize texture0Uniform;
@synthesize texture0Changed;
@synthesize texture0Index;

@synthesize texture1;
@synthesize texture1Uniform;
@synthesize texture1Changed;
@synthesize texture1Index;

// Attributes
@synthesize positions;
@synthesize positionsAttribute;
@synthesize positionsChanged;

@synthesize texCoords;
@synthesize texCoordsAttribute;
@synthesize texCoordsChanged;

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        projectionMatrix = Matrix4Identity;
        projectionMatrixUniform = -1;
        projectionMatrixChanged = YES;

        modelViewMatrix = Matrix4Identity;
        modelViewMatrixUniform = -1;
        modelViewMatrixChanged = YES;

        texture0 = NULL;
        texture0Uniform = -1;
        texture0Changed = YES;
        texture0Index = 0;

        texture1 = NULL;
        texture1Uniform = -1;
        texture1Changed = YES;
        texture1Index = 1;

        GLint theIndex = 0;

        positionsAttribute = theIndex++;
        positionsChanged = YES;

        texCoordsAttribute = theIndex++;
        texCoordsChanged = YES;

        }
    return self;
    }

- (void)update
    {
    [super update];
    //
    AssertOpenGLNoError_();

    if (projectionMatrixChanged == YES)
        {
        if (projectionMatrixUniform == -1)
            {
            projectionMatrixUniform = glGetUniformLocation(self.name, "u_projectionMatrix");
            }

        glUniformMatrix4fv(projectionMatrixUniform, 1, NO, &projectionMatrix.m[0][0]);;
        projectionMatrixChanged = NO;
        AssertOpenGLNoError_();
        }

    if (modelViewMatrixChanged == YES)
        {
        if (modelViewMatrixUniform == -1)
            {
            modelViewMatrixUniform = glGetUniformLocation(self.name, "u_modelViewMatrix");
            }

        glUniformMatrix4fv(modelViewMatrixUniform, 1, NO, &modelViewMatrix.m[0][0]);;
        modelViewMatrixChanged = NO;
        AssertOpenGLNoError_();
        }

    if (texture0Changed == YES)
        {
        if (texture0Uniform == -1)
            {
            texture0Uniform = glGetUniformLocation(self.name, "u_texture0");
            }

        [texture0 use:texture0Uniform index:texture0Index];
        texture0Changed = NO;
        AssertOpenGLNoError_();
        }

    if (texture1Changed == YES)
        {
        if (texture1Uniform == -1)
            {
            texture1Uniform = glGetUniformLocation(self.name, "u_texture1");
            }

        [texture1 use:texture1Uniform index:texture1Index];
        texture1Changed = NO;
        AssertOpenGLNoError_();
        }


    if (positionsChanged == YES)
        {
        if (positions)
            {
            [positions use:positionsAttribute];
            glEnableVertexAttribArray(positionsAttribute);

            positionsChanged = NO;
            AssertOpenGLNoError_();
            }
        }

    if (texCoordsChanged == YES)
        {
        if (texCoords)
            {
            [texCoords use:texCoordsAttribute];
            glEnableVertexAttribArray(texCoordsAttribute);

            texCoordsChanged = NO;
            AssertOpenGLNoError_();
            }
        }

    }

- (void)setProjectionMatrix:(Matrix4)inProjectionMatrix
    {
    projectionMatrix = inProjectionMatrix;
    projectionMatrixChanged = YES;
    }

- (void)setModelViewMatrix:(Matrix4)inModelViewMatrix
    {
    modelViewMatrix = inModelViewMatrix;
    modelViewMatrixChanged = YES;
    }

- (void)setTexture0:(CTexture *)inTexture0
    {
    texture0 = inTexture0;
    texture0Changed = YES;
    }

- (void)setTexture1:(CTexture *)inTexture1
    {
    texture1 = inTexture1;
    texture1Changed = YES;
    }


- (void)setPositions:(CVertexBufferReference *)inPositions
    {
    if (positions != inPositions)
        {
        positions = inPositions;
        positionsChanged = YES;
        }
    }

- (void)setTexCoords:(CVertexBufferReference *)inTexCoords
    {
    if (texCoords != inTexCoords)
        {
        texCoords = inTexCoords;
        texCoordsChanged = YES;
        }
    }


@end

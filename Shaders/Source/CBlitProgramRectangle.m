//
//  CBlitProgramRectangle.m
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CBlitProgramRectangle.h"

#import "OpenGLTypes.h"
#import "OpenGLIncludes.h"
#import "CTexture.h"
#import "CVertexBufferReference.h"

@interface CBlitProgramRectangle ()

// Uniforms
@property (readwrite, nonatomic, assign) GLint texture0Uniform;
@property (readwrite, nonatomic, assign) BOOL texture0Changed;
@property (readwrite, nonatomic, assign) GLint texture0Index;

@property (readwrite, nonatomic, assign) GLint colorUniform;
@property (readwrite, nonatomic, assign) BOOL colorChanged;

@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform;
@property (readwrite, nonatomic, assign) BOOL modelViewMatrixChanged;

@property (readwrite, nonatomic, assign) GLint projectionViewMatrixUniform;
@property (readwrite, nonatomic, assign) BOOL projectionViewMatrixChanged;

// Attributes
@property (readwrite, nonatomic, assign) GLint texCoordsAttribute;
@property (readwrite, nonatomic, assign) BOOL texCoordsChanged;

@property (readwrite, nonatomic, assign) GLint positionsAttribute;
@property (readwrite, nonatomic, assign) BOOL positionsChanged;

@end

@implementation CBlitProgramRectangle

// Uniforms
@synthesize texture0;
@synthesize texture0Uniform;
@synthesize texture0Changed;
@synthesize texture0Index;

@synthesize color;
@synthesize colorUniform;
@synthesize colorChanged;

@synthesize modelViewMatrix;
@synthesize modelViewMatrixUniform;
@synthesize modelViewMatrixChanged;

@synthesize projectionViewMatrix;
@synthesize projectionViewMatrixUniform;
@synthesize projectionViewMatrixChanged;

// Attributes
@synthesize texCoords;
@synthesize texCoordsAttribute;
@synthesize texCoordsChanged;

@synthesize positions;
@synthesize positionsAttribute;
@synthesize positionsChanged;

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        texture0 = NULL;
        texture0Uniform = -1;
        texture0Changed = YES;
        texture0Index = 0;

        color = (Color4f){ 1.0, 1.0, 1.0, 1.0 };
        colorUniform = -1;
        colorChanged = YES;

        modelViewMatrix = Matrix4Identity;
        modelViewMatrixUniform = -1;
        modelViewMatrixChanged = YES;

        projectionViewMatrix = Matrix4Identity;
        projectionViewMatrixUniform = -1;
        projectionViewMatrixChanged = YES;

        GLint theIndex = 0;

        texCoordsAttribute = theIndex++;
        texCoordsChanged = YES;

        positionsAttribute = theIndex++;
        positionsChanged = YES;

        }
    return self;
    }

- (void)update
    {
    [super update];
    //
    AssertOpenGLNoError_();

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

    if (colorChanged == YES)
        {
        if (colorUniform == -1)
            {
            colorUniform = glGetUniformLocation(self.name, "u_color");
            }

        glUniform4fv(colorUniform, 1, &color.r);
        colorChanged = NO;
        AssertOpenGLNoError_();
        }

    if (modelViewMatrixChanged == YES)
        {
        if (modelViewMatrixUniform == -1)
            {
            modelViewMatrixUniform = glGetUniformLocation(self.name, "u_modelViewMatrix");
            }

        glUniformMatrix4fv(modelViewMatrixUniform, 1, NO, &modelViewMatrix.m[0][0]);
        modelViewMatrixChanged = NO;
        AssertOpenGLNoError_();
        }

    if (projectionViewMatrixChanged == YES)
        {
        if (projectionViewMatrixUniform == -1)
            {
            projectionViewMatrixUniform = glGetUniformLocation(self.name, "u_projectionMatrix");
            }

        glUniformMatrix4fv(projectionViewMatrixUniform, 1, NO, &projectionViewMatrix.m[0][0]);
        projectionViewMatrixChanged = NO;
        AssertOpenGLNoError_();
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

    }

- (void)setTexture0:(CTexture *)inTexture0
    {
    texture0 = inTexture0;
    texture0Changed = YES;
    }

- (void)setColor:(Color4f)inColor
    {
    color = inColor;
    colorChanged = YES;
    }

- (void)setModelViewMatrix:(Matrix4)inModelViewMatrix
    {
    modelViewMatrix = inModelViewMatrix;
    modelViewMatrixChanged = YES;
    }

- (void)setProjectionViewMatrix:(Matrix4)inProjectionViewMatrix
    {
    projectionViewMatrix = inProjectionViewMatrix;
    projectionViewMatrixChanged = YES;
    }


- (void)setTexCoords:(CVertexBufferReference *)inTexCoords
    {
    if (texCoords != inTexCoords)
        {
        texCoords = inTexCoords;
        texCoordsChanged = YES;
        }
    }

- (void)setPositions:(CVertexBufferReference *)inPositions
    {
    if (positions != inPositions)
        {
        positions = inPositions;
        positionsChanged = YES;
        }
    }


@end

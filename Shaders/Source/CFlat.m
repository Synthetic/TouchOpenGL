//
//  CFlat.m
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CFlat.h"

#import "OpenGLTypes.h"
#import "OpenGLIncludes.h"

#import "CVertexBufferReference.h"

@interface CFlat ()

// Uniforms
@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform;
@property (readwrite, nonatomic, assign) BOOL modelViewMatrixChanged;

@property (readwrite, nonatomic, assign) GLint projectionMatrixUniform;
@property (readwrite, nonatomic, assign) BOOL projectionMatrixChanged;

@property (readwrite, nonatomic, assign) GLint colorUniform;
@property (readwrite, nonatomic, assign) BOOL colorChanged;

// Attributes
@property (readwrite, nonatomic, assign) GLint positionsAttribute;
@property (readwrite, nonatomic, assign) BOOL positionsChanged;

@property (readwrite, nonatomic, assign) GLint colorsAttribute;
@property (readwrite, nonatomic, assign) BOOL colorsChanged;

@end

@implementation CFlat

// Uniforms
@synthesize modelViewMatrix;
@synthesize modelViewMatrixUniform;
@synthesize modelViewMatrixChanged;

@synthesize projectionMatrix;
@synthesize projectionMatrixUniform;
@synthesize projectionMatrixChanged;

@synthesize color;
@synthesize colorUniform;
@synthesize colorChanged;

// Attributes
@synthesize positions;
@synthesize positionsAttribute;
@synthesize positionsChanged;

@synthesize colors;
@synthesize colorsAttribute;
@synthesize colorsChanged;

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        modelViewMatrix = Matrix4Identity;
        modelViewMatrixUniform = -1;
        modelViewMatrixChanged = YES;

        projectionMatrix = Matrix4Identity;
        projectionMatrixUniform = -1;
        projectionMatrixChanged = YES;

        color = (Color4f){ 1.0, 1.0, 1.0, 1.0 };
        colorUniform = -1;
        colorChanged = YES;

        GLint theIndex = 0;

        positionsAttribute = theIndex++;
        positionsChanged = YES;

        colorsAttribute = theIndex++;
        colorsChanged = YES;

        }
    return self;
    }

- (void)use
    {
    [super use];
    //
    AssertOpenGLNoError_();

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

    if (colorChanged == YES)
        {
        if (colorUniform == -1)
            {
            colorUniform = glGetUniformLocation(self.name, "u_color");
            }

        glUniform4fv(colorUniform, 1, &color.r);;
        colorChanged = NO;
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

    if (colorsChanged == YES)
        {
        if (colors)
            {
            [colors use:colorsAttribute];
            glEnableVertexAttribArray(colorsAttribute);

            colorsChanged = NO;
            AssertOpenGLNoError_();
            }
        }

    }

- (void)setModelViewMatrix:(Matrix4)inModelViewMatrix
    {
    modelViewMatrix = inModelViewMatrix;
    modelViewMatrixChanged = YES;
    }

- (void)setProjectionMatrix:(Matrix4)inProjectionMatrix
    {
    projectionMatrix = inProjectionMatrix;
    projectionMatrixChanged = YES;
    }

- (void)setColor:(Color4f)inColor
    {
    color = inColor;
    colorChanged = YES;
    }


- (void)setPositions:(CVertexBufferReference *)inPositions
    {
    if (positions != inPositions)
        {
        positions = inPositions;
        positionsChanged = YES;
        }
    }

- (void)setColors:(CVertexBufferReference *)inColors
    {
    if (colors != inColors)
        {
        colors = inColors;
        colorsChanged = YES;
        }
    }


@end

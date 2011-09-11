//
//  CFlatProgram.m
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CFlatProgram.h"

#import "OpenGLTypes.h"
#import "OpenGLIncludes.h"

#import "CVertexBufferReference.h"

@interface CFlatProgram ()
@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform; 
@property (readwrite, nonatomic, assign) GLint projectionMatrixUniform; 
@property (readwrite, nonatomic, assign) GLint positionsAttribute;
@property (readwrite, nonatomic, assign) GLint colorsAttribute;

@property (readwrite, nonatomic, assign) BOOL modelViewMatrixChanged; 
@property (readwrite, nonatomic, assign) BOOL projectionMatrixChanged; 
@property (readwrite, nonatomic, assign) BOOL positionsChanged;
@property (readwrite, nonatomic, assign) BOOL colorsChanged;
@end

@implementation CFlatProgram

@synthesize modelViewMatrix;
@synthesize projectionMatrix;
@synthesize positions;
@synthesize colors;

@synthesize modelViewMatrixUniform; 
@synthesize projectionMatrixUniform; 
@synthesize positionsAttribute;
@synthesize colorsAttribute;

@synthesize modelViewMatrixChanged; 
@synthesize projectionMatrixChanged; 
@synthesize positionsChanged;
@synthesize colorsChanged;

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        modelViewMatrix = Matrix4Identity;
        projectionMatrix = Matrix4Identity;
        
        modelViewMatrixUniform = -1;
        projectionMatrixUniform = -1;
        positionsAttribute = 0;
        colorsAttribute = 1;
        
        modelViewMatrixChanged = YES;
        projectionMatrixChanged = YES;
        positionsChanged = YES;
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
        glUniformMatrix4fv(modelViewMatrixUniform, 1, NO, &modelViewMatrix.m[0][0]);
        
        modelViewMatrixChanged = NO;
        }

    AssertOpenGLNoError_();

    if (projectionMatrixChanged == YES)
        {
        if (projectionMatrixUniform == -1)
            {
            projectionMatrixUniform = glGetUniformLocation(self.name, "u_projectionMatrix");
            }
        glUniformMatrix4fv(projectionMatrixUniform, 1, NO, &projectionMatrix.m[0][0]);
        
        projectionMatrixChanged = NO;
        }

    AssertOpenGLNoError_();

    if (positionsChanged == YES)
        {
        if (self.positions)
            {
            [self.positions use:positionsAttribute];
            glEnableVertexAttribArray(positionsAttribute);
            
            positionsChanged = NO;
            }
        }

    AssertOpenGLNoError_();

    if (colorsChanged == YES)
        {
        if (self.colors)
            {
            [self.colors use:colorsAttribute];
            glEnableVertexAttribArray(colorsAttribute);
            
            colorsChanged = NO;
            }
        }

    AssertOpenGLNoError_();
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

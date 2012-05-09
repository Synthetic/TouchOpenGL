//
//  CHSLAdjustmentProgram.m
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CHSLAdjustmentProgram.h"

#import "OpenGLTypes.h"
#import "OpenGLIncludes.h"
#import "CTexture.h"
#import "CVertexBufferReference.h"

#define ktexCoordsAttributeIndex 0
#define kpositionsAttributeIndex 1

@interface CHSLAdjustmentProgram ()

// Uniforms
@property (readwrite, nonatomic, assign) GLint texture0Uniform;
@property (readwrite, nonatomic, assign) GLint texture0Index;
@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform;
@property (readwrite, nonatomic, assign) GLint adjustmentUniform;
@property (readwrite, nonatomic, assign) GLint projectionMatrixUniform;

@end

@implementation CHSLAdjustmentProgram

// Uniforms
@synthesize texture0;
@synthesize texture0Uniform;
@synthesize texture0Index;
@synthesize modelViewMatrix;
@synthesize modelViewMatrixUniform;
@synthesize adjustment;
@synthesize adjustmentUniform;
@synthesize projectionMatrix;
@synthesize projectionMatrixUniform;

// Attributes
@synthesize texCoords;
@synthesize positions;

- (id)init
    {
    NSArray *theShaders = [NSArray arrayWithObjects:
        [[self class] loadShader:@"HSLAdjustment.fsh"],
        [[self class] loadShader:@"Default.vsh"],
        NULL
        ];

    if ((self = [self initWithShaders:theShaders]) != NULL)
        {
        [self bindAttribute:@"a_texCoord" location:ktexCoordsAttributeIndex];
        [self bindAttribute:@"a_position" location:kpositionsAttributeIndex];


		AssertOpenGLNoError_();

		NSError *theError = NULL;
		if ([self linkProgram:&theError] == NO)
		    {
		    NSLog(@"Could not link program (%@): %@", self, theError);
		    self = NULL;
		    return(self);
		    }

		AssertOpenGLNoError_();

        // texture0
        texture0 = NULL;
        texture0Uniform = -1;
        texture0Index = 0;
        // modelViewMatrix
        modelViewMatrix = Matrix4Identity;
        modelViewMatrixUniform = -1;
        // adjustment
        adjustment = (Vector3){};
        adjustmentUniform = -1;
        // projectionMatrix
        projectionMatrix = Matrix4Identity;
        projectionMatrixUniform = -1;
        }
    return self;
    }

- (void)update
    {
    [super update];
    //
    AssertOpenGLNoError_();

    // texture0
    if (texture0Uniform == -1)
        {
        texture0Uniform = glGetUniformLocation(self.name, "u_texture0");
        }

    if (texture0)
        {
        [texture0 use:texture0Uniform index:texture0Index];
        AssertOpenGLNoError_();
        }
    else
        {
        glBindTexture(GL_TEXTURE_2D, 0);
        }

    // modelViewMatrix
    if (modelViewMatrixUniform == -1)
        {
        modelViewMatrixUniform = glGetUniformLocation(self.name, "u_modelViewMatrix");
        }

    glUniformMatrix4fv(modelViewMatrixUniform, 1, NO, &modelViewMatrix.m[0][0]);
    AssertOpenGLNoError_();

    // adjustment
    if (adjustmentUniform == -1)
        {
        adjustmentUniform = glGetUniformLocation(self.name, "u_adjustment");
        }

    glUniform3fv(adjustmentUniform, 1, &adjustment.x);
    AssertOpenGLNoError_();

    // projectionMatrix
    if (projectionMatrixUniform == -1)
        {
        projectionMatrixUniform = glGetUniformLocation(self.name, "u_projectionMatrix");
        }

    glUniformMatrix4fv(projectionMatrixUniform, 1, NO, &projectionMatrix.m[0][0]);
    AssertOpenGLNoError_();


    // texCoords
    if (texCoords)
        {
        [texCoords use:ktexCoordsAttributeIndex];
        glEnableVertexAttribArray(ktexCoordsAttributeIndex);

        AssertOpenGLNoError_();
        }
    // positions
    if (positions)
        {
        [positions use:kpositionsAttributeIndex];
        glEnableVertexAttribArray(kpositionsAttributeIndex);

        AssertOpenGLNoError_();
        }
    }

@end

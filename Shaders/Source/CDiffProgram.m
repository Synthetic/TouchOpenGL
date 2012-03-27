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

#define ktexCoordsAttributeIndex 0
#define kpositionsAttributeIndex 1

@interface CDiffProgram ()

// Uniforms
@property (readwrite, nonatomic, assign) GLint texture1Uniform;
@property (readwrite, nonatomic, assign) GLint texture1Index;
@property (readwrite, nonatomic, assign) GLint texture0Uniform;
@property (readwrite, nonatomic, assign) GLint texture0Index;
@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform;
@property (readwrite, nonatomic, assign) GLint projectionMatrixUniform;

@end

@implementation CDiffProgram

// Uniforms
@synthesize texture1;
@synthesize texture1Uniform;
@synthesize texture1Index;
@synthesize texture0;
@synthesize texture0Uniform;
@synthesize texture0Index;
@synthesize modelViewMatrix;
@synthesize modelViewMatrixUniform;
@synthesize projectionMatrix;
@synthesize projectionMatrixUniform;

// Attributes
@synthesize texCoords;
@synthesize positions;

- (id)init
    {
    NSArray *theShaders = @[
        [[self class] loadShader:@"Diff.fsh"],
        [[self class] loadShader:@"Default.vsh"],
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

		theError = NULL;
		if ([self validate:&theError] == NO)
		    {
		    NSLog(@"Could not validate program (%@): %@", self, theError);
		    self = NULL;
		    return(self);
		    }

		AssertOpenGLNoError_();

        // texture1
        texture1 = NULL;
        texture1Uniform = -1;
        texture1Index = 0;
        // texture0
        texture0 = NULL;
        texture0Uniform = -1;
        texture0Index = 1;
        // modelViewMatrix
        modelViewMatrix = Matrix4Identity;
        modelViewMatrixUniform = -1;
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

    // texture1
    if (texture1Uniform == -1)
        {
        texture1Uniform = glGetUniformLocation(self.name, "u_texture1");
        }

    if (texture1)
        {
        [texture1 use:texture1Uniform index:texture1Index];
        AssertOpenGLNoError_();
        }
    else
        {
        glBindTexture(GL_TEXTURE_2D, 0);
        }

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

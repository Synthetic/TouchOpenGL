//
//  CBlurProgram.m
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CBlurProgram.h"

#import "OpenGLTypes.h"
#import "OpenGLIncludes.h"
#import "CTexture.h"
#import "CVertexBufferReference.h"

#define ktexCoordsAttributeIndex 0
#define kpositionsAttributeIndex 1

@interface CBlurProgram ()

// Uniforms
@property (readwrite, nonatomic, assign) GLint texture0Uniform;
@property (readwrite, nonatomic, assign) GLint texture0Index;
@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform;
@property (readwrite, nonatomic, assign) GLint textureSizeUniform;
@property (readwrite, nonatomic, assign) GLint verticalUniform;
@property (readwrite, nonatomic, assign) GLint projectionMatrixUniform;

@end

@implementation CBlurProgram

// Uniforms
@synthesize texture0;
@synthesize texture0Uniform;
@synthesize texture0Index;
@synthesize modelViewMatrix;
@synthesize modelViewMatrixUniform;
@synthesize textureSize;
@synthesize textureSizeUniform;
@synthesize vertical;
@synthesize verticalUniform;
@synthesize projectionMatrix;
@synthesize projectionMatrixUniform;

// Attributes
@synthesize texCoords;
@synthesize positions;

- (id)init
    {
    NSArray *theShaders = @[
        [[self class] loadShader:@"Blur.fsh"],
        [[self class] loadShader:@"Default.vsh"],
        ];

    if ((self = [self initWithShaders:theShaders]) != NULL)
        {
        [self bindAttribute:@"a_texCoord" location:ktexCoordsAttributeIndex];
        [self bindAttribute:@"a_position" location:kpositionsAttributeIndex];


		AssertOpenGLNoError_();

		[self linkProgram:NULL];

		NSError *theError = NULL;
		[self validate:&theError];

		AssertOpenGLNoError_();

        // texture0
        texture0 = NULL;
        texture0Uniform = -1;
        texture0Index = 0;
        // modelViewMatrix
        modelViewMatrix = Matrix4Identity;
        modelViewMatrixUniform = -1;
        // textureSize
        textureSize = (Vector2){};
        textureSizeUniform = -1;
        // vertical
        vertical = NO;
        verticalUniform = -1;
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

    // textureSize
    if (textureSizeUniform == -1)
        {
        textureSizeUniform = glGetUniformLocation(self.name, "u_textureSize");
        }

    glUniform2fv(textureSizeUniform, 1, &textureSize.x);
    AssertOpenGLNoError_();

    // vertical
    if (verticalUniform == -1)
        {
        verticalUniform = glGetUniformLocation(self.name, "u_vertical");
        }

    glUniform1i(verticalUniform, vertical);
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

//
//  CCompositeProgram.m
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CCompositeProgram.h"

#import "OpenGLTypes.h"
#import "OpenGLIncludes.h"
#import "CTexture.h"
#import "CVertexBufferReference.h"

#define ktexCoordsAttributeIndex 0
#define kpositionsAttributeIndex 1

@interface CCompositeProgram ()

// Uniforms
@property (readwrite, nonatomic, assign) GLint texture1Uniform;
@property (readwrite, nonatomic, assign) GLint texture1Index;
@property (readwrite, nonatomic, assign) GLint texture0Uniform;
@property (readwrite, nonatomic, assign) GLint texture0Index;
@property (readwrite, nonatomic, assign) GLint colorUniform;
@property (readwrite, nonatomic, assign) GLint projectionMatrixUniform;
@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform;
@property (readwrite, nonatomic, assign) GLint blendModeUniform;
@property (readwrite, nonatomic, assign) GLint alphaUniform;
@property (readwrite, nonatomic, assign) GLint gammaUniform;

@end

@implementation CCompositeProgram

// Uniforms
@synthesize texture1;
@synthesize texture1Uniform;
@synthesize texture1Index;
@synthesize texture0;
@synthesize texture0Uniform;
@synthesize texture0Index;
@synthesize color;
@synthesize colorUniform;
@synthesize projectionMatrix;
@synthesize projectionMatrixUniform;
@synthesize modelViewMatrix;
@synthesize modelViewMatrixUniform;
@synthesize blendMode;
@synthesize blendModeUniform;
@synthesize alpha;
@synthesize alphaUniform;
@synthesize gamma;
@synthesize gammaUniform;

// Attributes
@synthesize texCoords;
@synthesize positions;

- (id)init
    {
    NSArray *theUniformNames = @[
        @"u_texture1",
        @"u_texture0",
        @"u_color",
        @"u_projectionMatrix",
        @"u_modelViewMatrix",
        @"u_blendMode",
        @"u_alpha",
        @"u_gamma",
        ];

    NSArray *theShaders = @[
        [[self class] loadShader:@"CompositeTexture.fsh"],
        [[self class] loadShader:@"Default.vsh"],
        ];

    if ((self = [self initWithShaders:theShaders uniformNames:theUniformNames]) != NULL)
        {
        [self bindAttribute:@"a_texCoord" location:ktexCoordsAttributeIndex];
        [self bindAttribute:@"a_position" location:kpositionsAttributeIndex];


		AssertOpenGLNoError_();

		[self linkProgram:NULL];

		NSError *theError = NULL;
		[self validate:&theError];

		AssertOpenGLNoError_();

        // texture1
        texture1 = NULL;
        texture1Uniform = -1;
        texture1Index = 0;
        // texture0
        texture0 = NULL;
        texture0Uniform = -1;
        texture0Index = 1;
        // color
        color = (Color4f){ 0.0, 0.0, 0.0, 0.0 };
        colorUniform = -1;
        // projectionMatrix
        projectionMatrix = Matrix4Identity;
        projectionMatrixUniform = -1;
        // modelViewMatrix
        modelViewMatrix = Matrix4Identity;
        modelViewMatrixUniform = -1;
        // blendMode
        blendMode = 0;
        blendModeUniform = -1;
        // alpha
        alpha = 0.0;
        alphaUniform = -1;
        // gamma
        gamma = 0.0;
        gammaUniform = -1;
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

    // color
    if (colorUniform == -1)
        {
        colorUniform = glGetUniformLocation(self.name, "u_color");
        }

    glUniform4fv(colorUniform, 1, &color.r);
    AssertOpenGLNoError_();

    // projectionMatrix
    if (projectionMatrixUniform == -1)
        {
        projectionMatrixUniform = glGetUniformLocation(self.name, "u_projectionMatrix");
        }

    glUniformMatrix4fv(projectionMatrixUniform, 1, NO, &projectionMatrix.m[0][0]);
    AssertOpenGLNoError_();

    // modelViewMatrix
    if (modelViewMatrixUniform == -1)
        {
        modelViewMatrixUniform = glGetUniformLocation(self.name, "u_modelViewMatrix");
        }

    glUniformMatrix4fv(modelViewMatrixUniform, 1, NO, &modelViewMatrix.m[0][0]);
    AssertOpenGLNoError_();

    // blendMode
    if (blendModeUniform == -1)
        {
        blendModeUniform = glGetUniformLocation(self.name, "u_blendMode");
        }

    glUniform1i(blendModeUniform, blendMode);
    AssertOpenGLNoError_();

    // alpha
    if (alphaUniform == -1)
        {
        alphaUniform = glGetUniformLocation(self.name, "u_alpha");
        }

    glUniform1f(alphaUniform, alpha);
    AssertOpenGLNoError_();

    // gamma
    if (gammaUniform == -1)
        {
        gammaUniform = glGetUniformLocation(self.name, "u_gamma");
        }

    glUniform1f(gammaUniform, gamma);
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

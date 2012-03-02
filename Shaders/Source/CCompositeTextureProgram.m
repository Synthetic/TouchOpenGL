//
//  CCompositeTextureProgram.m
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CCompositeTextureProgram.h"

#import "OpenGLTypes.h"
#import "OpenGLIncludes.h"
#import "CTexture.h"
#import "CVertexBufferReference.h"

@interface CCompositeTextureProgram ()

// Uniforms
@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform;
@property (readwrite, nonatomic, assign) BOOL modelViewMatrixChanged;

@property (readwrite, nonatomic, assign) GLint projectionMatrixUniform;
@property (readwrite, nonatomic, assign) BOOL projectionMatrixChanged;

@property (readwrite, nonatomic, assign) GLint texture0Uniform;
@property (readwrite, nonatomic, assign) BOOL texture0Changed;
@property (readwrite, nonatomic, assign) GLint texture0Index;

@property (readwrite, nonatomic, assign) GLint texture1Uniform;
@property (readwrite, nonatomic, assign) BOOL texture1Changed;
@property (readwrite, nonatomic, assign) GLint texture1Index;

@property (readwrite, nonatomic, assign) GLint blendModeUniform;
@property (readwrite, nonatomic, assign) BOOL blendModeChanged;

@property (readwrite, nonatomic, assign) GLint gammaUniform;
@property (readwrite, nonatomic, assign) BOOL gammaChanged;

@property (readwrite, nonatomic, assign) GLint alphaUniform;
@property (readwrite, nonatomic, assign) BOOL alphaChanged;

@property (readwrite, nonatomic, assign) GLint colorUniform;
@property (readwrite, nonatomic, assign) BOOL colorChanged;

// Attributes
@property (readwrite, nonatomic, assign) GLint positionsAttribute;
@property (readwrite, nonatomic, assign) BOOL positionsChanged;

@property (readwrite, nonatomic, assign) GLint texCoordsAttribute;
@property (readwrite, nonatomic, assign) BOOL texCoordsChanged;

@end

@implementation CCompositeTextureProgram

// Uniforms
@synthesize modelViewMatrix;
@synthesize modelViewMatrixUniform;
@synthesize modelViewMatrixChanged;

@synthesize projectionMatrix;
@synthesize projectionMatrixUniform;
@synthesize projectionMatrixChanged;

@synthesize texture0;
@synthesize texture0Uniform;
@synthesize texture0Changed;
@synthesize texture0Index;

@synthesize texture1;
@synthesize texture1Uniform;
@synthesize texture1Changed;
@synthesize texture1Index;

@synthesize blendMode;
@synthesize blendModeUniform;
@synthesize blendModeChanged;

@synthesize gamma;
@synthesize gammaUniform;
@synthesize gammaChanged;

@synthesize alpha;
@synthesize alphaUniform;
@synthesize alphaChanged;

@synthesize color;
@synthesize colorUniform;
@synthesize colorChanged;

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
        modelViewMatrix = Matrix4Identity;
        modelViewMatrixUniform = -1;
        modelViewMatrixChanged = YES;

        projectionMatrix = Matrix4Identity;
        projectionMatrixUniform = -1;
        projectionMatrixChanged = YES;

        texture0 = NULL;
        texture0Uniform = -1;
        texture0Changed = YES;
        texture0Index = 0;

        texture1 = NULL;
        texture1Uniform = -1;
        texture1Changed = YES;
        texture1Index = 1;

        blendMode = 0;
        blendModeUniform = -1;
        blendModeChanged = YES;

        gamma = 0.0;
        gammaUniform = -1;
        gammaChanged = YES;

        alpha = 0.0;
        alphaUniform = -1;
        alphaChanged = YES;

        color = (Color4f){ 1.0, 1.0, 1.0, 1.0 };
        colorUniform = -1;
        colorChanged = YES;

        GLint theIndex = 0;

        positionsAttribute = theIndex++;
        positionsChanged = YES;

        texCoordsAttribute = theIndex++;
        texCoordsChanged = YES;
        }
    return self;
    }

- (void)reset
	{
	[super reset];

	modelViewMatrixUniform = -1;
	modelViewMatrixChanged = YES;

	projectionMatrixUniform = -1;
	projectionMatrixChanged = YES;

	texture0Uniform = -1;
	texture0Changed = YES;
	texture0Index = 0;

	texture1Uniform = -1;
	texture1Changed = YES;
	texture1Index = 1;

	blendModeUniform = -1;
	blendModeChanged = YES;

	gammaUniform = -1;
	gammaChanged = YES;

	alphaUniform = -1;
	alphaChanged = YES;

	colorUniform = -1;
	colorChanged = YES;

	positionsChanged = YES;

	texCoordsChanged = YES;
	}

- (void)update
    {
    [super update];
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

    if (blendModeChanged == YES)
        {
        if (blendModeUniform == -1)
            {
            blendModeUniform = glGetUniformLocation(self.name, "u_blendMode");
            }

        glUniform1i(blendModeUniform, blendMode);;
        blendModeChanged = NO;
        AssertOpenGLNoError_();
        }

    if (gammaChanged == YES)
        {
        if (gammaUniform == -1)
            {
            gammaUniform = glGetUniformLocation(self.name, "u_gamma");
            }

        glUniform1f(gammaUniform, gamma);;
        gammaChanged = NO;
        AssertOpenGLNoError_();
        }

    if (alphaChanged == YES)
        {
        if (alphaUniform == -1)
            {
            alphaUniform = glGetUniformLocation(self.name, "u_alpha");
            }

        glUniform1f(alphaUniform, alpha);;
        alphaChanged = NO;
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

- (void)setBlendMode:(GLint)inBlendMode
    {
    blendMode = inBlendMode;
    blendModeChanged = YES;
    }

- (void)setGamma:(GLfloat)inGamma
    {
    gamma = inGamma;
    gammaChanged = YES;
    }

- (void)setAlpha:(GLfloat)inAlpha
    {
    alpha = inAlpha;
    alphaChanged = YES;
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

- (void)setTexCoords:(CVertexBufferReference *)inTexCoords
    {
    if (texCoords != inTexCoords)
        {
        texCoords = inTexCoords;
        texCoordsChanged = YES;
        }
    }


@end

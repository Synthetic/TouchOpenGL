//
//  CChannelLookupProgram.m
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CChannelLookupProgram.h"

#import "OpenGLTypes.h"
#import "OpenGLIncludes.h"
#import "CTexture.h"
#import "CVertexBufferReference.h"

#define ktexCoordsAttributeIndex 0
#define kpositionsAttributeIndex 1

@interface CChannelLookupProgram ()

// Uniforms
@property (readwrite, nonatomic, assign) GLint texture0Uniform;
@property (readwrite, nonatomic, assign) GLint texture0Index;
@property (readwrite, nonatomic, assign) GLint blueLUTUniform;
@property (readwrite, nonatomic, assign) GLint blueLUTIndex;
@property (readwrite, nonatomic, assign) GLint greenLUTUniform;
@property (readwrite, nonatomic, assign) GLint greenLUTIndex;
@property (readwrite, nonatomic, assign) GLint projectionMatrixUniform;
@property (readwrite, nonatomic, assign) GLint redLUTUniform;
@property (readwrite, nonatomic, assign) GLint redLUTIndex;
@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform;

@end

@implementation CChannelLookupProgram

// Uniforms
@synthesize texture0;
@synthesize texture0Uniform;
@synthesize texture0Index;
@synthesize blueLUT;
@synthesize blueLUTUniform;
@synthesize blueLUTIndex;
@synthesize greenLUT;
@synthesize greenLUTUniform;
@synthesize greenLUTIndex;
@synthesize projectionMatrix;
@synthesize projectionMatrixUniform;
@synthesize redLUT;
@synthesize redLUTUniform;
@synthesize redLUTIndex;
@synthesize modelViewMatrix;
@synthesize modelViewMatrixUniform;

// Attributes
@synthesize texCoords;
@synthesize positions;

- (id)init
    {
    NSArray *theShaders = @[
        [[self class] loadShader:@"ChannelLookup_GL.fsh"],
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

		AssertOpenGLNoError_();

        // texture0
        texture0 = NULL;
        texture0Uniform = -1;
        texture0Index = 0;
        // blueLUT
        blueLUT = NULL;
        blueLUTUniform = -1;
        blueLUTIndex = 1;
        // greenLUT
        greenLUT = NULL;
        greenLUTUniform = -1;
        greenLUTIndex = 2;
        // projectionMatrix
        projectionMatrix = Matrix4Identity;
        projectionMatrixUniform = -1;
        // redLUT
        redLUT = NULL;
        redLUTUniform = -1;
        redLUTIndex = 3;
        // modelViewMatrix
        modelViewMatrix = Matrix4Identity;
        modelViewMatrixUniform = -1;
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

    // blueLUT
    if (blueLUTUniform == -1)
        {
        blueLUTUniform = glGetUniformLocation(self.name, "u_blueLUT");
        }

    if (blueLUT)
        {
        [blueLUT use:blueLUTUniform index:blueLUTIndex];
        AssertOpenGLNoError_();
        }
    else
        {
        glBindTexture(GL_TEXTURE_1D, 0);
        }

    // greenLUT
    if (greenLUTUniform == -1)
        {
        greenLUTUniform = glGetUniformLocation(self.name, "u_greenLUT");
        }

    if (greenLUT)
        {
        [greenLUT use:greenLUTUniform index:greenLUTIndex];
        AssertOpenGLNoError_();
        }
    else
        {
        glBindTexture(GL_TEXTURE_1D, 0);
        }

    // projectionMatrix
    if (projectionMatrixUniform == -1)
        {
        projectionMatrixUniform = glGetUniformLocation(self.name, "u_projectionMatrix");
        }

    glUniformMatrix4fv(projectionMatrixUniform, 1, NO, &projectionMatrix.m[0][0]);
    AssertOpenGLNoError_();

    // redLUT
    if (redLUTUniform == -1)
        {
        redLUTUniform = glGetUniformLocation(self.name, "u_redLUT");
        }

    if (redLUT)
        {
        [redLUT use:redLUTUniform index:redLUTIndex];
        AssertOpenGLNoError_();
        }
    else
        {
        glBindTexture(GL_TEXTURE_1D, 0);
        }

    // modelViewMatrix
    if (modelViewMatrixUniform == -1)
        {
        modelViewMatrixUniform = glGetUniformLocation(self.name, "u_modelViewMatrix");
        }

    glUniformMatrix4fv(modelViewMatrixUniform, 1, NO, &modelViewMatrix.m[0][0]);
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

//
//  CBlitRectangleProgram.m
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CBlitRectangleProgram.h"

#import "OpenGLTypes.h"
#import "OpenGLIncludes.h"
#import "CTexture.h"
#import "CVertexBufferReference.h"

@interface CBlitRectangleProgram ()

// Uniforms
@property (readwrite, nonatomic, assign) GLint texture0Uniform;
@property (readwrite, nonatomic, assign) GLint texture0Index;
@property (readwrite, nonatomic, assign) GLint colorUniform;
@property (readwrite, nonatomic, assign) GLint modelViewMatrixUniform;
@property (readwrite, nonatomic, assign) GLint projectionMatrixUniform;

// Attributes
@property (readwrite, nonatomic, assign) GLint texCoordsIndex;
@property (readwrite, nonatomic, assign) GLint positionsIndex;

@end

@implementation CBlitRectangleProgram

- (id)init
    {
    NSArray *theShaders = @[
        [[self class] loadShader:@"BlitTextureRectangle.fsh"],
        [[self class] loadShader:@"Default.vsh"],
        ];

    if ((self = [self initWithShaders:theShaders]) != NULL)
        {
		NSError *theError = NULL;
		if ([self linkProgram:&theError] == NO)
		    {
		    NSLog(@"Could not link program (%@): %@", self, theError);
		    self = NULL;
		    return(self);
		    }

		AssertOpenGLNoError_();

        // texture0
        _texture0 = NULL;
        _texture0Uniform = -1;
        _texture0Index = 0;
        // color
        _color = (Color4f){ 0.0, 0.0, 0.0, 0.0 };
        _colorUniform = -1;
        // modelViewMatrix
        _modelViewMatrix = Matrix4Identity;
        _modelViewMatrixUniform = -1;
        // projectionMatrix
        _projectionMatrix = Matrix4Identity;
        _projectionMatrixUniform = -1;

        }
    return self;
    }

- (void)update
    {
    [super update];
    //
    AssertOpenGLNoError_();

    // texture0
    if (_texture0Uniform == -1)
        {
        _texture0Uniform = glGetUniformLocation(self.name, "u_texture0");
        }

    [_texture0 use:_texture0Uniform index:_texture0Index];
    AssertOpenGLNoError_();

    // color
    if (_colorUniform == -1)
        {
        _colorUniform = glGetUniformLocation(self.name, "u_color");
        }

    glUniform4fv(_colorUniform, 1, &_color.r);
    AssertOpenGLNoError_();

    // modelViewMatrix
    if (_modelViewMatrixUniform == -1)
        {
        _modelViewMatrixUniform = glGetUniformLocation(self.name, "u_modelViewMatrix");
        }

    glUniformMatrix4fv(_modelViewMatrixUniform, 1, NO, &_modelViewMatrix.m[0][0]);
    AssertOpenGLNoError_();

    // projectionMatrix
    if (_projectionMatrixUniform == -1)
        {
        _projectionMatrixUniform = glGetUniformLocation(self.name, "u_projectionMatrix");
        }

    glUniformMatrix4fv(_projectionMatrixUniform, 1, NO, &_projectionMatrix.m[0][0]);
    AssertOpenGLNoError_();



    if (_texCoords)
        {
        _texCoordsIndex = glGetAttribLocation(self.name, "a_texCoord");

        [_texCoords use:_texCoordsIndex];
        glEnableVertexAttribArray(_texCoordsIndex);

        AssertOpenGLNoError_();
        }

    if (_positions)
        {
        _positionsIndex = glGetAttribLocation(self.name, "a_position");

        [_positions use:_positionsIndex];
        glEnableVertexAttribArray(_positionsIndex);

        AssertOpenGLNoError_();
        }
    }

@end

//
//  CAutomagicBlitProgram.m
//  SimpleTextureTest
//
//  Created by Jonathan Wight on 3/18/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CAutomagicBlitProgram.h"

#import "CTexture.h"
#import "CVertexBufferReference.h"
#import "CTextureUnit.h"

#import <objc/runtime.h>

#define ktexCoordsAttributeIndex 0
#define kpositionsAttributeIndex 1

@interface CAutomagicBlitProgram ()
@end

@implementation CAutomagicBlitProgram

- (id)init
    {
    NSArray *theShaders = @[
        [[self class] loadShader:@"BlitTexture.fsh"],
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
        _textureUnit0 = [[CTextureUnit alloc] initWithIndex:0];
        // color
        _color = (Color4f){ 0.0, 0.0, 0.0, 0.0 };
        // modelViewMatrix
        _modelViewMatrix = Matrix4Identity;
        // projectionMatrix
        _projectionMatrix = Matrix4Identity;
        }
    return self;
    }

#pragma mark -

- (ProgramUpdateBlock)updateBlockForTextureUnitProperty:(NSString *)inPropertyName uniformName:(NSString *)inUniformName
	{
	__block GLint theUniform = -1;

	ProgramUpdateBlock theBlock = ^(void) {
		CTextureUnit *theTextureUnit = [self valueForKey:inPropertyName];
		if (theTextureUnit.texture)
			{
			if (theUniform == -1)
				{
				theUniform = glGetUniformLocation(self.name, [inUniformName UTF8String]);
				}

			[theTextureUnit use:theUniform];

			AssertOpenGLNoError_();
			}
		else
			{
			glBindTexture(theTextureUnit.texture.target, 0);
			}
		};

	return(theBlock);
	}

- (ProgramUpdateBlock)updateBlockForColorUnitProperty:(NSString *)inPropertyName uniformName:(NSString *)inUniformName
	{
	__block GLint theUniform = -1;
	ProgramUpdateBlock theBlock = ^(void) {
	
		// color
		if (theUniform == -1)
			{
			theUniform = glGetUniformLocation(self.name, "u_color");
			}

		glUniform4fv(theUniform, 1, &_color.r);
		AssertOpenGLNoError_();
		};

	return(theBlock);
	}

#pragma mark -

- (NSArray *)updateBlocks
	{
	NSMutableArray *theUpdateBlocks = [NSMutableArray array];
	
	ProgramUpdateBlock theBlock = NULL;
	
	// #########################################################################
	theBlock = [self updateBlockForTextureUnitProperty:@"textureUnit0" uniformName:@"u_texture0"];
	[theUpdateBlocks addObject:[theBlock copy]];

	// #########################################################################
	__block GLint _colorUniform = -1;
	theBlock = ^(void) {
		// color
		if (_colorUniform == -1)
			{
			_colorUniform = glGetUniformLocation(self.name, "u_color");
			}

		glUniform4fv(_colorUniform, 1, &_color.r);
		AssertOpenGLNoError_();
		};
	[theUpdateBlocks addObject:[theBlock copy]];

	// #########################################################################
	__block GLint _modelViewMatrixUniform = -1;
	theBlock = ^(void) {
		if (_modelViewMatrixUniform == -1)
			{
			_modelViewMatrixUniform = glGetUniformLocation(self.name, "u_modelViewMatrix");
			}

		glUniformMatrix4fv(_modelViewMatrixUniform, 1, NO, &_modelViewMatrix.m[0][0]);
		AssertOpenGLNoError_();
		};
	[theUpdateBlocks addObject:[theBlock copy]];

	// #########################################################################
	__block GLint _projectionMatrixUniform = -1;
	theBlock = ^(void) {
		if (_projectionMatrixUniform == -1)
			{
			_projectionMatrixUniform = glGetUniformLocation(self.name, "u_projectionMatrix");
			}

		glUniformMatrix4fv(_projectionMatrixUniform, 1, NO, &_projectionMatrix.m[0][0]);
		AssertOpenGLNoError_();
		};
	[theUpdateBlocks addObject:[theBlock copy]];

	// #########################################################################
	theBlock = ^(void) {
		if (_texCoords)
			{
			[_texCoords use:ktexCoordsAttributeIndex];
			glEnableVertexAttribArray(ktexCoordsAttributeIndex);

			AssertOpenGLNoError_();
			}
		};
	[theUpdateBlocks addObject:[theBlock copy]];

	// #########################################################################
	theBlock = ^(void) {
		if (_positions)
			{
			[_positions use:kpositionsAttributeIndex];
			glEnableVertexAttribArray(kpositionsAttributeIndex);

			AssertOpenGLNoError_();
			}
		};
	[theUpdateBlocks addObject:[theBlock copy]];
		
	return(theUpdateBlocks);
	}

@end

//
//  CTestRenderer.m
//  SimpleTextureTest
//
//  Created by Jonathan Wight on 3/19/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CTestRenderer.h"

#import "CAutomagicBlitProgram.h"
#import "CAssetLibrary.h"
#import "CVertexBufferReference_FactoryExtensions.h"
#import "CTexture.h"
#import "CTextureUnit.h"

@interface CTestRenderer ()
@end

#pragma mark -

@implementation CTestRenderer

- (void)setup
	{
	[super setup];
	
	if (self.program == NULL)
		{
		self.program = [[CAutomagicBlitProgram alloc] init];
		[self.program use];
		self.program.texCoords = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ .size = { 1.0, 1.0 } }];
		self.program.positions = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ -1, -1, 2, 2 }];
		self.program.projectionMatrix = Matrix4MakeScale(-1.0, -1.0, 1.0);
		}
	}

- (void)render
    {
	[super render];

	if (self.texture != NULL)
		{
		[self.program use];
		self.program.textureUnit0.texture = self.texture;
		[self.program update];

		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glFlush();
		}
	}

- (void)setTexture:(CTexture *)texture
	{
	if (_texture != texture)
		{
		_texture = texture;
		//
		self.program.texCoords = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ .size = { 1.0, 1.0 } }];
		}
	}

@end



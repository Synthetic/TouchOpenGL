//
//  CTextureRenderer.m
//  VideoFilterToy_OSX
//
//  Created by Jonathan Wight on 3/6/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CTextureRenderer.h"

#import "CBlitProgram.h"
#import "CBlitRectangleProgram.h"
#import "CAssetLibrary.h"
#import "CVertexBufferReference_FactoryExtensions.h"
#import "CTexture.h"

@interface CTextureRenderer ()
@property (readwrite, nonatomic, strong) CBlitRectangleProgram *rectangleProgram;
@end

#pragma mark -

@implementation CTextureRenderer

- (void)setup
	{
	[super setup];
	
	if (self.program == NULL)
		{
		self.program = [[CBlitProgram alloc] init];
		[self.program use];
		self.program.texCoords = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ .size = { 1.0, 1.0 } }];
		self.program.positions = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ -1, -1, 2, 2 }];
		self.program.projectionMatrix = Matrix4MakeScale(-1.0, -1.0, 1.0);
		}
	
	#if TARGET_OS_IPHONE == 0
	if (self.rectangleProgram == NULL)
		{
		self.rectangleProgram = [[CBlitRectangleProgram alloc] init];
		[self.rectangleProgram use];
		self.rectangleProgram.texCoords = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ .size = { 1.0, 1.0 } }];
		self.rectangleProgram.positions = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ -1, -1, 2, 2 }];
		self.rectangleProgram.projectionMatrix = Matrix4MakeScale(-1.0, -1.0, 1.0);
		}
	#endif
	}

- (void)render
    {
	[super render];

	if (self.texture != NULL)
		{
		#if TARGET_OS_IPHONE == 0
		if (_texture.target == GL_TEXTURE_RECTANGLE_ARB)
			{
			[self.rectangleProgram use];
			self.rectangleProgram.texture0 = self.texture;
			[self.rectangleProgram update];
			}
		else
		#endif /* TARGET_OS_IPHONE == 0 */
			{
			[self.program use];
			self.program.texture0 = self.texture;
			[self.program update];
			}

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
		#if TARGET_OS_IPHONE == 0
		if (_texture.target == GL_TEXTURE_RECTANGLE_ARB)
			{
			self.rectangleProgram.texCoords = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ .size = { self.texture.size.width, self.texture.size.height } }];
			}
		else
		#endif /* TARGET_OS_IPHONE == 0 */
			{
			self.program.texCoords = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ .size = { 1.0, 1.0 } }];
			}
		}
	}

@end




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
#import "CTexture_Utilities.h"

@interface CTextureRenderer ()
@end

#pragma mark -

@implementation CTextureRenderer

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        _projectionMatrix = Matrix4Identity;
        }
    return self;
    }

- (void)setup
	{
	[super setup];
	//
	AssertOpenGLNoError_();

	if (self.program == NULL)
		{
		self.program = [[CBlitProgram alloc] init];

        [self.program use];

        self.program.texCoords = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ .size = { 1, 1 } }];
        self.program.positions = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ -1, -1, 2, 2 }];
        self.program.projectionMatrix = self.projectionMatrix;
        self.program.modelViewMatrix = Matrix4Identity;
        }
    }

- (void)render
    {
	[super render];
	
    NSLog(@"DRAW BEGIN");

	AssertOpenGLNoError_();
	
    CTexture *theTexture = NULL;

    if (self.textureBlock != NULL)
        {
        theTexture = self.textureBlock();
        }

	if (theTexture == NULL)
        {
        return;
        }

    self.program.texture0 = theTexture;

    AssertOpenGLNoError_();

    [self.program update];

    AssertOpenGLNoError_();

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    AssertOpenGLNoError_();

    NSLog(@"DRAW DONE");
	}

@end



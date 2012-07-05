//
//  CTextureRenderer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 3/6/12.
//  Copyright 2012 Jonathan Wight. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Jonathan Wight.

#import "CTextureRenderer.h"

#import "CBlitProgram.h"
#import "CBlitRectangleProgram.h"
#import "CAssetLibrary.h"
#import "CVertexBufferReference.h"
#import "CTexture.h"

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



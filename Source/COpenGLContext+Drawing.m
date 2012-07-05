//
//  COpenGLContext+Drawing.m
//  VideoFilterToy_OSX
//
//  Created by Jonathan Wight on 3/12/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "COpenGLContext+Drawing.h"

#import "CBlitProgram.h" 
#import "CVertexBufferReference.h"
#import "CVertexBuffer.h"

@implementation COpenGLContext (Drawing)

- (void)strokeRect:(CGRect)inRect color:(Color4f)inColor
	{
	[self strokeRect:inRect color:inColor transform:Matrix4Identity];
	}

- (void)strokeRect:(CGRect)inRect color:(Color4f)inColor transform:(Matrix4f)inTransform
	{
    AssertOpenGLNoError_();

    const Vector3f theVertices[] = {
        { CGRectGetMinX(inRect), CGRectGetMinY(inRect), 0 },
        { CGRectGetMaxX(inRect), CGRectGetMinY(inRect), 0 },
        { CGRectGetMaxX(inRect), CGRectGetMaxY(inRect), 0 },
        { CGRectGetMinX(inRect), CGRectGetMaxY(inRect), 0 },
        };

    NSData *theData = [NSData dataWithBytes:theVertices length:sizeof(theVertices)];
    CVertexBuffer *theBuffer = [[CVertexBuffer alloc] initWithTarget:GL_ARRAY_BUFFER usage:GL_STATIC_DRAW data:theData];
    CVertexBufferReference *theReference = [[CVertexBufferReference alloc] initWithVertexBuffer:theBuffer cellEncoding:@encode(Vector3f) normalized:NO];

    AssertOpenGLNoError_();

	CBlitProgram *theBlitProgram = [[CBlitProgram alloc] init];
	[theBlitProgram use];
	theBlitProgram.texture0 = NULL;
	theBlitProgram.positions = theReference;
	theBlitProgram.texCoords = NULL;
	theBlitProgram.color = inColor;
	theBlitProgram.projectionMatrix = inTransform;
	[theBlitProgram update];

    AssertOpenGLNoError_();

	glLineWidth(1.0);

	glDrawArrays(GL_LINE_LOOP, 0, 4);

    AssertOpenGLNoError_();
	}

@end

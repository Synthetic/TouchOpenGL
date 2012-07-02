//
//  CVertexBufferReference_FactoryExtensions.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 01/31/11.
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

#import "CVertexBufferReference_FactoryExtensions.h"

#import "CVertexBuffer.h"
#import "OpenGLTypes.h"

#if TARGET_OS_IPHONE
#import "UIColor_OpenGLExtensions.h"
#else
#import "NSColor_OpenGLExtensions.h"
#endif

@implementation CVertexBufferReference (CVertexBufferReference_FactoryExtensions)

+ (CVertexBufferReference *)vertexBufferReferenceWithIndices:(NSArray *)inIndices;
    {
    NSMutableData *theData = [NSMutableData dataWithCapacity:inIndices.count * sizeof(GLushort)];

    GLushort *V = theData.mutableBytes;

    for (NSNumber *theNumber in inIndices)
        {
        *V++ = [theNumber unsignedShortValue];
        }
    
    CVertexBuffer *theBuffer = [[CVertexBuffer alloc] initWithTarget:GL_ELEMENT_ARRAY_BUFFER usage:GL_STATIC_DRAW data:theData];
    CVertexBufferReference *theReference = [[CVertexBufferReference alloc] initWithVertexBuffer:theBuffer cellEncoding:@encode(GLushort) normalized:NO];
    return(theReference);
    }

+ (CVertexBufferReference *)vertexBufferReferenceWithRect:(CGRect)inRect
    {
    const Vector3 theVertices[] = {
        { CGRectGetMinX(inRect), CGRectGetMinY(inRect), 0 },
        { CGRectGetMaxX(inRect), CGRectGetMinY(inRect), 0 },
        { CGRectGetMinX(inRect), CGRectGetMaxY(inRect), 0 },
        { CGRectGetMaxX(inRect), CGRectGetMaxY(inRect), 0 },
        };

    NSData *theData = [NSData dataWithBytes:theVertices length:sizeof(theVertices)];
    CVertexBuffer *theBuffer = [[CVertexBuffer alloc] initWithTarget:GL_ARRAY_BUFFER usage:GL_STATIC_DRAW data:theData];
    CVertexBufferReference *theReference = [[CVertexBufferReference alloc] initWithVertexBuffer:theBuffer cellEncoding:@encode(typeof(theVertices[0])) normalized:NO];
    return(theReference);
    }
    
+ (CVertexBufferReference *)vertexBufferReferenceWithColors:(NSArray *)inColors;
    {
    NSMutableData *theData = [NSMutableData dataWithLength:sizeof(Color4ub) * [inColors count]];
    
    Color4ub *V = theData.mutableBytes;
    
    for (id theColor in inColors)
        {
        *V++ = [theColor color4ub];
        }
    
    CVertexBuffer *theBuffer = [[CVertexBuffer alloc] initWithTarget:GL_ARRAY_BUFFER usage:GL_STATIC_DRAW data:theData];
    CVertexBufferReference *theReference = [[CVertexBufferReference alloc] initWithVertexBuffer:theBuffer cellEncoding:@encode(Color4ub) normalized:NO];
    return(theReference);
    }

+ (CVertexBufferReference *)vertexBufferReferenceWithCircleWithRadius:(GLfloat)inRadius center:(CGPoint)inCenter points:(NSInteger)inPoints
    {
    NSMutableData *theData = [NSMutableData dataWithLength:sizeof(Vector2) * (inPoints + 2)];

    Vector2 *V = theData.mutableBytes;
    
    *V++ = (Vector2){ inCenter.x, inCenter.y };

    for (NSInteger N = 0; N != inPoints + 1; ++N)
        {
        double theta = (double)N / (double)inPoints * 2 * M_PI;
        
        *V++ = (Vector2){ cos(theta) * inRadius + inCenter.x, sin(theta) * inRadius + inCenter.y };
        }

    CVertexBuffer *theBuffer = [[CVertexBuffer alloc] initWithTarget:GL_ARRAY_BUFFER usage:GL_STATIC_DRAW data:theData];
    CVertexBufferReference *theReference = [[CVertexBufferReference alloc] initWithVertexBuffer:theBuffer cellEncoding:@encode(Vector2) normalized:NO];
    return(theReference);
    }


@end

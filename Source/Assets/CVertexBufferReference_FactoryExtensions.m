//
//  CVertexBufferReference_FactoryExtensions.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 01/31/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

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

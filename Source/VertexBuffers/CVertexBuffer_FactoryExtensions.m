//
//  CVertexBuffer_FactoryExtensions.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 01/31/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CVertexBuffer_FactoryExtensions.h"

#import "OpenGLTypes.h"

#if TARGET_OS_IPHONE
#import "UIColor_OpenGLExtensions.h"
#else
#import "NSColor_OpenGLExtensions.h"
#endif

@implementation CVertexBuffer (CVertexBuffer_FactoryExtensions)

+ (id)vertexBufferWithIndices:(NSArray *)inIndices;
    {
    NSMutableData *theData = [NSMutableData dataWithCapacity:inIndices.count * sizeof(GLushort)];
    
    for (NSNumber *theNumber in inIndices)
        {
        GLushort theShort = [theNumber unsignedShortValue];
        [theData appendBytes:&theShort length:sizeof(theShort)];
        }
    
    CVertexBuffer *theBuffer = [[self alloc] initWithTarget:GL_ELEMENT_ARRAY_BUFFER usage:GL_STATIC_DRAW data:theData];
    return(theBuffer);
    }

+ (id)vertexBufferWithRect:(CGRect)inRect
    {
    const Vector3 theVertices[] = {
        { CGRectGetMinX(inRect), CGRectGetMinY(inRect), 0 },
        { CGRectGetMaxX(inRect), CGRectGetMinY(inRect), 0 },
        { CGRectGetMinX(inRect), CGRectGetMaxY(inRect), 0 },
        { CGRectGetMaxX(inRect), CGRectGetMaxY(inRect), 0 },
        };

    NSData *theData = [NSData dataWithBytes:theVertices length:sizeof(theVertices)];
    CVertexBuffer *theVertexBuffer = [[self alloc] initWithTarget:GL_ARRAY_BUFFER usage:GL_STATIC_DRAW data:theData];
    
    return(theVertexBuffer);
    }
    
+ (id)vertexBufferWithColors:(NSArray *)inColors;
    {
    NSMutableData *theData = [NSMutableData dataWithLength:sizeof(Color4ub) * [inColors count]];
    
    Color4ub *V = theData.mutableBytes;
    
    for (id theColor in inColors)
        {
        *V++ = [theColor color4ub];
        }
    
    CVertexBuffer *theVertexBuffer = [[self alloc] initWithTarget:GL_ARRAY_BUFFER usage:GL_STATIC_DRAW data:theData];
    return(theVertexBuffer);
    }

+ (id)vertexBufferWithCircleWithRadius:(GLfloat)inRadius points:(NSInteger)inPoints
    {
    NSMutableData *theData = [NSMutableData dataWithLength:sizeof(Vector2) * (inPoints + 2)];

    Vector2 *V = theData.mutableBytes;
    
    *V++ = (Vector2){ 0.0, 0.0 };

    for (NSInteger N = 0; N != inPoints + 1; ++N)
        {
        double theta = (double)N / (double)inPoints * 2 * M_PI;
        
        *V++ = (Vector2){ cos(theta) * inRadius, sin(theta) * inRadius };
        }

    CVertexBuffer *theVertexBuffer = [[self alloc] initWithTarget:GL_ARRAY_BUFFER usage:GL_STATIC_DRAW data:theData];
    
    return(theVertexBuffer);
    }


@end

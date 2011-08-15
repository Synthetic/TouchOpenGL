//
//  CGeometry.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/22/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CGeometry.h"

#import "CVertexArrayBuffer.h"
#import "CVertexBufferReference.h"
#import "CMaterial.h"

@implementation CGeometry

@synthesize vertexArrayBuffer;
@synthesize indices;
@synthesize positions;
@synthesize texCoords;
@synthesize normals;
@synthesize material;

- (CVertexArrayBuffer *)vertexArrayBuffer
    {
    #if TARGET_OS_IPHONE
    if (vertexArrayBuffer == NULL)
        {
        vertexArrayBuffer = [[CVertexArrayBuffer alloc] init];
        }
    return(vertexArrayBuffer);
    #else
    return(NULL);
    #endif /* TARGET_OS_IPHONE */
    }

@end

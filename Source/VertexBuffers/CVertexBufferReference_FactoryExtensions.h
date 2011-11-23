//
//  CVertexBuffer_FactoryExtensions.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 01/31/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CVertexBufferReference.h"

@interface CVertexBufferReference (CVertexBufferReference_FactoryExtensions)

+ (CVertexBufferReference *)vertexBufferReferenceWithIndices:(NSArray *)inIndices;
+ (CVertexBufferReference *)vertexBufferReferenceWithRect:(CGRect)inRect;
+ (CVertexBufferReference *)vertexBufferReferenceWithColors:(NSArray *)inColors;
+ (CVertexBufferReference *)vertexBufferReferenceWithCircleWithRadius:(GLfloat)inRadius center:(CGPoint)inCenter points:(NSInteger)inPoints;

@end

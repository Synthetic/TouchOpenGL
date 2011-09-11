//
//  CVertexBuffer_FactoryExtensions.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 01/31/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CVertexBuffer.h"

@interface CVertexBuffer (CVertexBuffer_FactoryExtensions)

+ (id)vertexBufferWithIndices:(NSArray *)inIndices;
+ (id)vertexBufferWithRect:(CGRect)inRect;
+ (id)vertexBufferWithColors:(NSArray *)inColors;
+ (id)vertexBufferWithCircleWithRadius:(GLfloat)inRadius points:(NSInteger)inPoints;

@end

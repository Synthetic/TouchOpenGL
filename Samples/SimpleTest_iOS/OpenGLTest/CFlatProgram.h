//
//  CFlatProgram.h
//  Dwarf
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CProgram.h"

#import "Matrix.h"

@class CVertexBufferReference;

@interface CFlatProgram : CProgram

@property (readwrite, nonatomic, assign) Matrix4 modelViewMatrix; 
@property (readwrite, nonatomic, assign) Matrix4 projectionMatrix;
@property (readwrite, nonatomic, retain) CVertexBufferReference *positions;
@property (readwrite, nonatomic, retain) CVertexBufferReference *colors;


@end

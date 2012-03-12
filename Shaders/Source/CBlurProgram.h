//
//  CBlurProgram.h
//  <#some project>
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CProgram.h"

#import "Matrix.h"

@class CTexture;

@class CVertexBufferReference;

@interface CBlurProgram : CProgram

// Uniforms
@property (readwrite, nonatomic, strong) CTexture * texture0;
@property (readonly, nonatomic, assign) GLint texture0Index;
@property (readwrite, nonatomic, assign) Matrix4 modelViewMatrix;
@property (readwrite, nonatomic, assign) GLboolean vertical;
@property (readwrite, nonatomic, assign) Matrix4 projectionViewMatrix;

// Attributes
@property (readwrite, nonatomic, retain) CVertexBufferReference *texCoords;
@property (readwrite, nonatomic, retain) CVertexBufferReference *positions;

@end

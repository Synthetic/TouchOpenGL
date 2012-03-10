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
@property (readwrite, nonatomic, assign) Matrix4 projectionMatrix;
@property (readwrite, nonatomic, assign) Matrix4 modelViewMatrix;
@property (readwrite, nonatomic, strong) CTexture * texture0;
@property (readonly, nonatomic, assign) GLint texture0Index;
@property (readwrite, nonatomic, assign) GLfloat blurRadius;
@property (readwrite, nonatomic, assign) GLboolean vertical;

// Attributes
@property (readwrite, nonatomic, retain) CVertexBufferReference *positions;
@property (readwrite, nonatomic, retain) CVertexBufferReference *texCoords;

@end

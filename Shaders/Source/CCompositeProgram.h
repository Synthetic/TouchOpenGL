//
//  CCompositeProgram.h
//  <#some project>
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CProgram.h"

#import "Matrix.h"

@class CTexture;
@class CVertexBufferReference;

@interface CCompositeProgram : CProgram

// Uniforms
@property (readwrite, nonatomic, strong) CTexture * texture1;
@property (readonly, nonatomic, assign) GLint texture1Index;
@property (readwrite, nonatomic, strong) CTexture * texture0;
@property (readonly, nonatomic, assign) GLint texture0Index;
@property (readwrite, nonatomic, assign) Color4f color;
@property (readwrite, nonatomic, assign) Matrix4 projectionMatrix;
@property (readwrite, nonatomic, assign) Matrix4 modelViewMatrix;
@property (readwrite, nonatomic, assign) GLint blendMode;
@property (readwrite, nonatomic, assign) GLfloat alpha;
@property (readwrite, nonatomic, assign) GLfloat gamma;

// Attributes
@property (readwrite, nonatomic, retain) CVertexBufferReference *texCoords;
@property (readwrite, nonatomic, retain) CVertexBufferReference *positions;

@end

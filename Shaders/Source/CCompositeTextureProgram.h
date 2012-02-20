//
//  CCompositeTextureProgram.h
//  <#some project>
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CProgram.h"

#import "Matrix.h"

@class CTexture;

@class CVertexBufferReference;

@interface CCompositeTextureProgram : CProgram

// Uniforms
@property (readwrite, nonatomic, assign) Matrix4 modelViewMatrix;
@property (readwrite, nonatomic, assign) Matrix4 projectionMatrix;
@property (readwrite, nonatomic, strong) CTexture * texture0;
@property (readwrite, nonatomic, strong) CTexture * texture1;
@property (readwrite, nonatomic, assign) GLint blendMode;
@property (readwrite, nonatomic, assign) GLfloat gamma;
@property (readwrite, nonatomic, assign) GLfloat alpha;

// Attributes
@property (readwrite, nonatomic, retain) CVertexBufferReference *positions;
@property (readwrite, nonatomic, retain) CVertexBufferReference *texCoords;

@end

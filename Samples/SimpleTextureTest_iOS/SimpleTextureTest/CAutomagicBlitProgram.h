//
//  CAutomagicBlitProgram.h
//  SimpleTextureTest
//
//  Created by Jonathan Wight on 3/18/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CAutomagicProgram.h"

#import "Matrix.h"

@class CTextureUnit;
@class CVertexBufferReference;

@interface CAutomagicBlitProgram : CAutomagicProgram

// Uniforms
@property (readwrite, nonatomic, strong) CTextureUnit * textureUnit0;
@property (readwrite, nonatomic, assign) Color4f color;
@property (readwrite, nonatomic, assign) Matrix4 modelViewMatrix;
@property (readwrite, nonatomic, assign) Matrix4 projectionMatrix;

// Attributes
@property (readwrite, nonatomic, retain) CVertexBufferReference *texCoords;
@property (readwrite, nonatomic, retain) CVertexBufferReference *positions;

@end

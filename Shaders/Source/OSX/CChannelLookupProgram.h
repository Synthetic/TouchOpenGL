//
//  CChannelLookupProgram.h
//  <#some project>
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CProgram.h"

#import "Matrix.h"

@class CTexture;
@class CVertexBufferReference;

@interface CChannelLookupProgram : CProgram

// Uniforms
@property (readwrite, nonatomic, strong) CTexture * texture0;
@property (readonly, nonatomic, assign) GLint texture0Index;
@property (readwrite, nonatomic, strong) CTexture * blueLUT;
@property (readonly, nonatomic, assign) GLint blueLUTIndex;
@property (readwrite, nonatomic, strong) CTexture * greenLUT;
@property (readonly, nonatomic, assign) GLint greenLUTIndex;
@property (readwrite, nonatomic, assign) Matrix4 projectionMatrix;
@property (readwrite, nonatomic, strong) CTexture * redLUT;
@property (readonly, nonatomic, assign) GLint redLUTIndex;
@property (readwrite, nonatomic, assign) Matrix4 modelViewMatrix;

// Attributes
@property (readwrite, nonatomic, retain) CVertexBufferReference *texCoords;
@property (readwrite, nonatomic, retain) CVertexBufferReference *positions;

@end

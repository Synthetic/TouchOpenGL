//
//  CTextureRenderer.h
//  VideoFilterToy_OSX
//
//  Created by Jonathan Wight on 3/6/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CBlockRenderer.h"

#import "Matrix.h"

@class CTexture;
@class CBlitProgram;

@interface CTextureRenderer : CBlockRenderer

@property (readwrite, nonatomic, strong) CTexture *texture;
@property (readwrite, nonatomic, copy) CTexture *(^textureBlock)(void);
@property (readwrite, nonatomic, strong) CBlitProgram *program;
@property (readwrite, nonatomic, assign) Matrix4 projectionMatrix;

@end

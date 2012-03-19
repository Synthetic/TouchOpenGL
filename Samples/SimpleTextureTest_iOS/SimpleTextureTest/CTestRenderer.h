//
//  CTestRenderer.h
//  SimpleTextureTest
//
//  Created by Jonathan Wight on 3/19/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CBlockRenderer.h"

@class CTexture;
@class CAutomagicBlitProgram;

@interface CTestRenderer : CBlockRenderer

@property (readwrite, nonatomic, strong) CTexture *texture;
@property (readwrite, nonatomic, strong) CAutomagicBlitProgram *program;

@end

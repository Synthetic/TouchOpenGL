//
//  COpenGLOffscreenContext.h
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "COpenGLContext.h"

@class CFrameBuffer;
@class CTexture;
@class CRenderBuffer;

@interface COpenGLOffscreenContext : COpenGLContext

@property (readonly, nonatomic, assign) SIntSize size;
@property (readonly, nonatomic, strong) CFrameBuffer *frameBuffer;
@property (readonly, nonatomic, strong) CTexture *texture;
@property (readonly, nonatomic, strong) CRenderBuffer *depthBuffer;

- (id)initWithSize:(SIntSize)inSize;

- (BOOL)start:(NSError **)outError;
- (CTexture *)detachTexture;
- (CGImageRef)fetchImage CF_RETURNS_RETAINED;

@end

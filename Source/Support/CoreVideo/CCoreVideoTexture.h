//
//  CCoreVideoTexture.h
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/23/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CTexture.h"

#import <CoreVideo/CoreVideo.h>

@interface CCoreVideoTexture : CTexture

- (id)initWithCVImageBuffer:(CVImageBufferRef)inImageBuffer textureCache:(CVOpenGLESTextureCacheRef)inTextureCache;
- (id)initWithSize:(SIntSize)inSize textureCache:(CVOpenGLESTextureCacheRef)inTextureCache;

@end

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

@property (readonly, nonatomic, assign) CVOpenGLTextureRef texture;
@property (readonly, nonatomic, assign) CVPixelBufferRef pixelBuffer;

- (id)initWithCVPixelBuffer:(CVPixelBufferRef)inPixelBuffer;
- (id)initWithSize:(SIntSize)inSize pixelFormat:(OSType)inPixelFormat;
- (id)initWithSize:(SIntSize)inSize;

@end

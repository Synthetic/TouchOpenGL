//
//  COpenGLContext_CoreVideoExtensions.h
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/28/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "COpenGLContext.h"

#import <CoreVideo/CoreVideo.h>

@interface COpenGLContext (COpenGLContext_CoreVideoExtensions)

@property (readonly, nonatomic, assign) CVOpenGLTextureCacheRef textureCache;

@end

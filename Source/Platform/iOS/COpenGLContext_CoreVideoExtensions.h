//
//  COpenGLContext_CoreVideoExtensions.h
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/28/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "COpenGLContext.h"

@interface COpenGLContext (COpenGLContext_CoreVideoExtensions)

#if TARGET_OS_IPHONE == 1
@property (readonly, nonatomic, assign) CVOpenGLESTextureCacheRef textureCache;
#endif /* TARGET_OS_IPHONE == 1 */

@end

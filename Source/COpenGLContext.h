//
//  COpenGLContext.h
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpenGLTypes.h"

@class CFrameBuffer;
@class CRenderBuffer;
@class CTexture;
@class CAssetLibrary;

@interface COpenGLContext : NSObject

@property (readwrite, nonatomic, strong) NSString *label;
@property (readonly, nonatomic, assign) BOOL isActive;
#if TARGET_OS_IPHONE == 1
@property (readonly, nonatomic, strong) EAGLContext *nativeContext;
#else
@property (readonly, nonatomic, assign) CGLContextObj nativeContext;
#endif /* TARGET_OS_IPHONE == 1 */
@property (readonly, nonatomic, strong) CAssetLibrary *assetLibrary;

+ (COpenGLContext *)currentContext;

- (id)init;

- (void)use;
- (void)unuse;

- (CTexture *)readTextureSize:(SIntSize)inSize;

@end

#pragma mark -

#if TARGET_OS_IPHONE == 1
@interface COpenGLContext (iOS)
- (id)initWithDrawable:(id <EAGLDrawable>)inDrawable;
- (void)present;
@end
#endif /* TARGET_OS_IPHONE == 1 */

#pragma mark -

#if TARGET_OS_IPHONE == 0
@interface COpenGLContext (MacOSX)
- (id)initWithNativeContext:(CGLContextObj)inNativeContext;
@end
#endif /* TARGET_OS_IPHONE == 0 */

//
//  COpenGLContext.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 2/20/12.
//  Copyright 2012 Jonathan Wight. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Jonathan Wight.

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

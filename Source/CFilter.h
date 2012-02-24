//
//  CFilter.h
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/21/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpenGLTypes.h"

@class COpenGLContext;
@class CTexture;

@interface CFilter : NSObject

@property (readonly, nonatomic, assign) SIntSize size;
@property (readwrite, nonatomic, strong) COpenGLContext *context;
@property (readonly, nonatomic, strong) CTexture *workingTexture;

- (id)initWithContext:(COpenGLContext *)inContext size:(SIntSize)inSize;

- (void)start:(CTexture *)inStartTexture;

- (void)filter:(void (^)(CTexture *texture))inFilter;

- (CTexture *)finish;

@end

//
//  CAssetLibrary.h
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/29/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "COpenGLContext.h"
#import "CAssetLibrary.h"

@class CTexture;
@class CProgram;

@interface CAssetLibrary : NSObject

@property (readonly, nonatomic, weak) COpenGLContext *context;
@property (readwrite, nonatomic, strong) NSArray *searchDirectoryURLs;

- (id)initWithContext:(COpenGLContext *)inContext;

- (void)flushCache;

- (CTexture *)textureNamed:(NSString *)inName error:(NSError **)outError;
- (CTexture *)textureNamed:(NSString *)inName cache:(BOOL)inCache error:(NSError **)outError;

- (CProgram *)programNamed:(NSString *)inName error:(NSError **)outError;

@end

#pragma mark -

@interface COpenGLContext (COpenGLContext_AssetLibraryExtension)

@property (readonly, nonatomic, strong) CAssetLibrary *assetLibrary;

@end
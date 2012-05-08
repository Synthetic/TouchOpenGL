//
//  COpenGLAsset.h
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/21/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpenGLIncludes.h"

@protocol COpenGLAsset <NSObject>

@property (readonly, nonatomic, assign) GLuint name;

@optional
- (void)invalidate;
- (void)load;

@end

@interface COpenGLAsset : NSObject <COpenGLAsset>

@property (readonly, nonatomic, assign) GLuint name;
@property (readonly, nonatomic, assign) BOOL named;
@property (readonly, nonatomic, assign) NSString *objectLabel;
@property (readwrite, nonatomic, strong) NSString *label;
@property (readonly, nonatomic, assign) GLuint cost;

+ (GLenum)type;

- (id)initWithName:(GLuint)inName;

- (void)invalidate;

@end

#pragma mark -

@interface COpenGLAsset (Debugging)
+ (BOOL)debug;
+ (void)trackAsset:(COpenGLAsset *)inAsset;
+ (void)untrackAsset:(COpenGLAsset *)inAsset;
+ (void)clearTrackedAssets;
+ (void)dumpActiveAssets;
@end

#pragma #pragma mark -

@interface COpenGLAsset (COpenGLAsset_Private)

@property (readwrite, nonatomic, assign) GLuint name;

@end

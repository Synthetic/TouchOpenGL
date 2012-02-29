//
//  COpenGLContext_CoreVideoExtensions.m
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/28/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "COpenGLContext_CoreVideoExtensions.h"

#import <objc/runtime.h>

@implementation COpenGLContext (COpenGLContext_CoreVideoExtensions)

static void *kKey;

- (CVOpenGLESTextureCacheRef)textureCache
	{
	CVOpenGLESTextureCacheRef theTextureCache = (__bridge CVOpenGLESTextureCacheRef)objc_getAssociatedObject(self, &kKey);
	if (theTextureCache == NULL)
		{
		CVReturn theResult = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge void *)self.nativeContext, NULL, &theTextureCache);


		objc_setAssociatedObject(self, &kKey, (__bridge id)theTextureCache, OBJC_ASSOCIATION_RETAIN);
		}
	return(theTextureCache);
	}

@end

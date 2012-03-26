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

- (CVOpenGLTextureCacheRef)textureCache
	{
	CVOpenGLTextureCacheRef theTextureCache = (__bridge CVOpenGLTextureCacheRef)objc_getAssociatedObject(self, &kKey);
	if (theTextureCache == NULL)
		{
		[self use];
		
		CVReturn theResult = CVOpenGLTextureCacheCreate(kCFAllocatorDefault, NULL, self.nativeContext, CGLGetPixelFormat(self.nativeContext), NULL, &theTextureCache);
		if (theResult != kCVReturnSuccess)
			{
			NSLog(@"CVOpenGLTextureCacheCreate failed with %d", theResult);
			}
		
		
		objc_setAssociatedObject(self, &kKey, (__bridge id)theTextureCache, OBJC_ASSOCIATION_RETAIN);
		}
	return(theTextureCache);
	}

@end

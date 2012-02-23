//
//  COpenGLContext.m
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "COpenGLContext.h"

#import "OpenGLIncludes.h"

#import "CFrameBuffer.h"
#import "CRenderBuffer.h"
#import "CTexture.h"

@interface COpenGLContext ()
- (void)setup;
- (void)logInfo;
@end

#pragma mark -

@implementation COpenGLContext

@synthesize nativeContext;

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
		[self setup];
        }
    return self;
    }

- (void)dealloc
	{
	#if TARGET_OS_IPHONE == 1
	if ([EAGLContext currentContext] == self.nativeContext)
		{
		[EAGLContext setCurrentContext:NULL];
		}
	#else
	if (CGLGetCurrentContext() == nativeContext)
		{
		CGLSetCurrentContext(nativeContext);
		}
	CGLDestroyContext(nativeContext);
	nativeContext = NULL;
	#endif
	}

- (void)setup
	{
	#if TARGET_OS_IPHONE == 1
	EAGLSharegroup *theShareGroup = [[EAGLSharegroup alloc] init];
	nativeContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:theShareGroup];
	#else
	CGLPixelFormatAttribute thePixelFormatAttributes[] = {
		kCGLPFAAccelerated,
		kCGLPFAColorSize, 8,
		kCGLPFAAlphaSize, 8,
		kCGLPFADepthSize, 16,
		0
		};
	CGLPixelFormatObj thePixelFormatObject = NULL;
	GLint theNumberOfPixelFormats = 0;
	CGLChoosePixelFormat(thePixelFormatAttributes, &thePixelFormatObject, &theNumberOfPixelFormats);
	if (thePixelFormatObject == NULL)
		{
		NSLog(@"Error: Could not choose pixel format!");
		}

	CGLContextObj theOpenGLContext = NULL;
	CGLError theError = CGLCreateContext(thePixelFormatObject, NULL, &theOpenGLContext);
	if (theError != kCGLNoError)
		{
		NSLog(@"Could not create context");
		return;
		}
	
	nativeContext = theOpenGLContext;
	#endif /* TARGET_OS_IPHONE == 1 */
	}

- (void)use
	{
	#if TARGET_OS_IPHONE == 1
	[EAGLContext setCurrentContext:self.nativeContext];
	#else
	
	CGLSetCurrentContext(self.nativeContext);
	
	#endif

//	[self logInfo];
	}

- (void)logInfo
	{
//	NSMutableDictionary *d = [NSMutableDictionary dictionary];
//	
//	#define X(d, K) do { \
//		GLint V = -1; \
//		glGetIntegerv(K, &V); \
//		[d setObject:[NSNumber numberWithInt:V] forKey:[NSString stringWithUTF8String:#K]]; \
//		} while (0); 
//
//	X(d, GL_MAX_TEXTURE_UNITS);
	
//	NSLog(@"%@", d);
	}

@end

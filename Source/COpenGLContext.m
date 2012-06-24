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
#import "CAssetLibrary.h"

@interface COpenGLContext ()

#if TARGET_OS_IPHONE == 1
@property (readwrite, nonatomic, weak) id <EAGLDrawable> drawable;
#endif
@end

#pragma mark -

@implementation COpenGLContext

@synthesize assetLibrary = _assetLibrary;

static COpenGLContext *gCurrentContext = NULL;

+ (COpenGLContext *)currentContext
	{
	return(gCurrentContext);
	}

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
	if ([EAGLContext currentContext] == _nativeContext)
		{
		[EAGLContext setCurrentContext:NULL];
		}
	#else
	if (CGLGetCurrentContext() == _nativeContext)
		{
		CGLSetCurrentContext(_nativeContext);
		}
	CGLDestroyContext(_nativeContext);
	_nativeContext = NULL;
	#endif
	}

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (%@)", [super description], self.label]);
    }

- (void)setup
	{
	if (_nativeContext == NULL)
		{
		#if TARGET_OS_IPHONE == 1
		_nativeContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		#else
		CGLPixelFormatAttribute thePixelFormatAttributes[] = {
			kCGLPFAAccelerated,
			kCGLPFAColorSize, 8,
			kCGLPFAAlphaSize, 8,
			kCGLPFADepthSize, 16,
            kCGLPFAOpenGLProfile, kCGLOGLPVersion_3_2_Core,
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
		
		_nativeContext = theOpenGLContext;
		#endif /* TARGET_OS_IPHONE == 1 */
		}
	}

- (BOOL)isActive
	{
	#if TARGET_OS_IPHONE == 1
	return([EAGLContext currentContext] == self.nativeContext);
	#else
	return(CGLGetCurrentContext() == _nativeContext);
	#endif
	}

- (CAssetLibrary *)assetLibrary
	{
	if (_assetLibrary == NULL)
		{
		_assetLibrary = [[CAssetLibrary alloc] initWithContext:self];
		}
	return(_assetLibrary);
	}

- (void)use
	{
    AssertOpenGLNoError_();

	gCurrentContext = self;
	
	#if TARGET_OS_IPHONE == 1
	[EAGLContext setCurrentContext:self.nativeContext];
	#else
	CGLSetCurrentContext(self.nativeContext);
	#endif

    AssertOpenGLNoError_();
	}
	
- (void)unuse
	{
	#if TARGET_OS_IPHONE == 1
	if ([EAGLContext currentContext] == self.nativeContext)
		{
		[EAGLContext setCurrentContext:NULL];
		}
	#else
	if (CGLGetCurrentContext() == _nativeContext)
		{
		CGLSetCurrentContext(NULL);
		}
	#endif
	}

- (CTexture *)readTextureSize:(SIntSize)inSize
	{
	NSMutableData *theData = [NSMutableData dataWithLength:inSize.width * 4 * inSize.height];

	GLint theReadFormat = GL_RGBA;
	GLint theReadType = GL_UNSIGNED_BYTE;

	glReadPixels(0, 0, inSize.width, inSize.height, theReadFormat, theReadType, theData.mutableBytes);

	CTexture *theTexture = [[CTexture alloc] initWithTarget:GL_TEXTURE_2D size:inSize format:GL_RGBA type:GL_UNSIGNED_BYTE];
	
    [theTexture bind];

    // Configure texture...
	glTexParameteri(theTexture.target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(theTexture.target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(theTexture.target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(theTexture.target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);   


    // Update texture data...
    glTexImage2D(GL_TEXTURE_2D, 0, theReadFormat, inSize.width, inSize.height, 0, theReadFormat, theReadType, theData.bytes);
	
	return(theTexture);
	}

@end

#pragma mark -

#if TARGET_OS_IPHONE == 1
@implementation COpenGLContext (iOS)

- (id)initWithDrawable:(id <EAGLDrawable>)inDrawable;
	{
    if ((self = [super init]) != NULL)
        {
		_drawable = inDrawable;

		[self setup];
        }
    return self;
	}

- (void)present
	{
    AssertOpenGLNoError_();

	[self.colorBuffer bind];
	AssertOpenGLNoError_();

	[self.nativeContext presentRenderbuffer:GL_RENDERBUFFER];
	}

@end
#endif /* TARGET_OS_IPHONE == 1 */

#pragma mark -

#if TARGET_OS_IPHONE == 0
@implementation COpenGLContext (MacOSX)

- (id)initWithNativeContext:(CGLContextObj)inNativeContext
    {
	NSParameterAssert(inNativeContext != NULL);
    if ((self = [super init]) != NULL)
        {
        _nativeContext = inNativeContext;
		
		[self setup];
        }
    return self;
    }


@end
#endif /* TARGET_OS_IPHONE == 0 */

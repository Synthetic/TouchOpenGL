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

@property (readwrite, nonatomic, strong) CFrameBuffer *frameBuffer;
@property (readwrite, nonatomic, strong) CRenderBuffer *depthBuffer;
@property (readwrite, nonatomic, strong) CRenderBuffer *colorBuffer;

#if TARGET_OS_IPHONE == 1
@property (readwrite, nonatomic, weak) id <EAGLDrawable> drawable;
#endif

- (void)setup;
- (void)logInfo;
@end

#pragma mark -

@implementation COpenGLContext

static COpenGLContext *gCurrentContext = NULL;

+ (COpenGLContext *)currentContext
	{
	return(gCurrentContext);
	}

- (id)initWithSize:(SIntSize)inSize
    {
    if ((self = [super init]) != NULL)
        {
		_size = inSize;

		[self setup];
        }
    return self;
    }
	
#if TARGET_OS_IPHONE == 1
- (id)initWithSize:(SIntSize)inSize drawable:(id <EAGLDrawable>)inDrawable;
	{
    if ((self = [super init]) != NULL)
        {
		_size = inSize;
		_drawable = inDrawable;

		[self setup];
        }
    return self;
	}
#else
- (id)initWithNativeContext:(CGLContextObj)inNativeContext size:(SIntSize)inSize
    {
    if ((self = [super init]) != NULL)
        {
		_size = inSize;
        _nativeContext = inNativeContext;
		
		[self setup];
        }
    return self;
    }
#endif

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

- (void)setup
	{
	if (_nativeContext == NULL)
		{
		#if TARGET_OS_IPHONE == 1
		EAGLSharegroup *theShareGroup = [[EAGLSharegroup alloc] init];
		_nativeContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:theShareGroup];
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
		
		_nativeContext = theOpenGLContext;
		#endif /* TARGET_OS_IPHONE == 1 */

		}
	}
	
- (void)setupFrameBuffer
	{
	NSParameterAssert(_frameBuffer == NULL);

	[self use];
		
	// #########################################################################

    self.frameBuffer = [[CFrameBuffer alloc] initWithTarget:GL_FRAMEBUFFER];
	self.frameBuffer.label = [NSString stringWithFormat:@"Framebuffer (%d)", self.frameBuffer.name];
    [self.frameBuffer bind];
    
    // Create a color render buffer - and configure it with current context & drawable
    self.colorBuffer = [[CRenderBuffer alloc] init];
	
	#warning TODO This a bit of a mess - and shouldn't be here...
#if TARGET_OS_IPHONE == 1
    [self.colorBuffer storageFromContext:self.nativeContext drawable:self.drawable];
#endif

    // Attach color buffer to frame buffer
    [self.frameBuffer attachObject:self.colorBuffer attachment:GL_COLOR_ATTACHMENT0];
    
    // Create a depth buffer - and configure it to the size of the color buffer.
    self.depthBuffer = [[CRenderBuffer alloc] init];
    [self.depthBuffer storage:GL_DEPTH_COMPONENT16 size:self.size];

    // Attach depth buffer to the frame buffer
    [self.frameBuffer attachObject:self.depthBuffer attachment:GL_DEPTH_ATTACHMENT];

    // Make sure the frame buffer has a complete set of render buffers.

	if ([self.frameBuffer isComplete] == NO)
        {
		NSLog(@"createFramebuffer failed %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
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

- (void)use
	{
	gCurrentContext = self;
	
	#if TARGET_OS_IPHONE == 1
	[EAGLContext setCurrentContext:self.nativeContext];
	#else
	CGLSetCurrentContext(self.nativeContext);
	#endif
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

- (void)present;
	{
    AssertOpenGLNoError_();

	[self.colorBuffer bind];
//		[self.context.frameBuffer discard];
	AssertOpenGLNoError_();

	#if TARGET_OS_IPHONE
	[self.nativeContext presentRenderbuffer:GL_RENDERBUFFER];
	#endif /* TARGET_OS_IPHONE */
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

- (CTexture *)readTexture
	{
	NSMutableData *theData = [NSMutableData dataWithLength:self.size.width * 4 * self.size.height];

	GLint theReadFormat = GL_RGBA;
	GLint theReadType = GL_UNSIGNED_BYTE;

	glReadPixels(0, 0, self.size.width, self.size.height, theReadFormat, theReadType, theData.mutableBytes);

	CTexture *theTexture = [[CTexture alloc] initWithTarget:GL_TEXTURE_2D size:self.size format:GL_RGBA type:GL_UNSIGNED_BYTE];
	
    [theTexture bind];

    // Configure texture...
	glTexParameteri(theTexture.target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(theTexture.target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(theTexture.target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(theTexture.target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);   


    // Update texture data...
    glTexImage2D(GL_TEXTURE_2D, 0, theReadFormat, self.size.width, self.size.height, 0, theReadFormat, theReadType, theData.bytes);
	
	return(theTexture);
	}

@end

//
//  CFilter.m
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/21/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CFilter.h"

#import "COpenGLContext.h"
#import "COpenGLOffscreenContext.h"
#import "CTexture_Utilities.h"
#import "CFrameBuffer.h"
#import "CRenderBuffer.h"

@interface CFilter ()
@property (readwrite, nonatomic, assign) SIntSize size;
@property (readwrite, nonatomic, strong) CFrameBuffer *frameBuffer;
@property (readwrite, nonatomic, strong) CTexture *texture;
@property (readwrite, nonatomic, strong) CTexture *workingTexture;
@end

#pragma mark -

@implementation CFilter

- (id)initWithContext:(COpenGLContext *)inContext size:(SIntSize)inSize
    {
    if ((self = [super init]) != NULL)
        {
		_context = inContext;
		_size = inSize;
		
		[_context use];

		AssertOpenGLValidContext_();
		
		self.frameBuffer = [[CFrameBuffer alloc] init];
		[self.frameBuffer bind];

		self.texture = [[CTexture alloc] initWithSize:self.size];
		[self.frameBuffer attachObject:self.texture attachment:GL_COLOR_ATTACHMENT0];

		GLenum theStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER); 
		if (theStatus != GL_FRAMEBUFFER_COMPLETE)
			{
			NSLog(@"glCheckFramebufferStatus failed: %@", NSStringFromGLenum(theStatus));
			}

		glViewport(0, 0, self.size.width, self.size.height);

		glDisable(GL_BLEND);

		glDisable(GL_DEPTH_TEST);

		glClearColor(255, 255, 255, 255);
        }
    return self;
    }

#pragma mark -

- (void)start:(CTexture *)inStartTexture
	{
	[self.context use];
	[self.frameBuffer bind];
	[self.texture bind];

	self.workingTexture = inStartTexture;
	}

- (void)filter:(void (^)(CTexture *texture))inFilter;
	{
	NSParameterAssert(inFilter != NULL);

	AssertOpenGLNoError_();

	inFilter(self.workingTexture);

	AssertOpenGLNoError_();

	self.workingTexture = [self detachTexture];
	}

- (CTexture *)finish;
	{
	return(self.workingTexture);
	}

- (CTexture *)detachTexture
	{
	AssertOpenGLValidContext_();
	AssertOpenGLNoError_();

//	[self.frameBuffer unbind];

	// Snag a copy of the texture...
	CTexture *theDetachedTexture = self.texture;
	[theDetachedTexture bind];
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);   



	[self.frameBuffer detachObject:theDetachedTexture attachment:GL_COLOR_ATTACHMENT0];

	// Create a new texture...
	// TODO doing this _EVERY_ frame will be expense
	self.texture = [[CTexture alloc] initWithSize:self.size];

	// Attach it to the frame buffer...
	[self.frameBuffer attachObject:self.texture attachment:GL_COLOR_ATTACHMENT0];
	if ([self.frameBuffer isComplete] == NO)
		{
		NSLog(@"Frame buffer not complete.");
		}

	AssertOpenGLNoError_();

	return(theDetachedTexture);
	}

@end

//
//  COpenGLOffscreenContext.m
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "COpenGLOffscreenContext.h"

#import "OpenGLIncludes.h"

#import "CFrameBuffer.h"
#import "CRenderBuffer.h"
#import "CTexture.h"

@interface COpenGLOffscreenContext ()
@property (readwrite, nonatomic, strong) CFrameBuffer *frameBuffer;
@property (readwrite, nonatomic, strong) CTexture *texture;
@end

#pragma mark -

@implementation COpenGLOffscreenContext

- (void)setupFrameBuffer
	{
	AssertOpenGLValidContext_();
	NSParameterAssert(self.frameBuffer == NULL);
	NSParameterAssert(_texture == NULL);
	
	self.frameBuffer = [[CFrameBuffer alloc] init];
	self.frameBuffer.label = [NSString stringWithFormat:@"Offscreen framebuffer (%d)", self.frameBuffer.name];
	[self.frameBuffer bind];

	self.texture = [[CTexture alloc] initWithSize:self.size];
	[self.frameBuffer attachObject:self.texture attachment:GL_COLOR_ATTACHMENT0];

	GLenum theStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER); 
	if (theStatus != GL_FRAMEBUFFER_COMPLETE)
		{
		NSLog(@"glCheckFramebufferStatus failed: %@", NSStringFromGLenum(theStatus));
		}
	}

- (BOOL)start:(NSError **)outError
	{
	AssertOpenGLValidContext_();
	AssertOpenGLNoError_();

	// #########################################################################

	glViewport(0, 0, self.size.width, self.size.height);

    glDisable(GL_BLEND);

    glDisable(GL_DEPTH_TEST);

	// Green
    glClearColor(0.0, 1.0, 0.0, 1.0);

    glClear(GL_COLOR_BUFFER_BIT);

	AssertOpenGLNoError_();
	
	return(YES);
	}

- (CTexture *)detachTexture
	{
	AssertOpenGLValidContext_();
	AssertOpenGLNoError_();

//	[self.frameBuffer unbind];

	// Snag a copy of the texture...
	CTexture *theDetachedTexture = self.texture;

	[self.frameBuffer detachObject:theDetachedTexture attachment:GL_COLOR_ATTACHMENT0];

	// Create a new texture...
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

- (CGImageRef)fetchImage
	{
	return([self.frameBuffer fetchImage:(self.size)]);
	}


@end

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
@property (readwrite, nonatomic, strong) CRenderBuffer *colorBuffer;
@end

#pragma mark -

@implementation COpenGLOffscreenContext

@synthesize size;
@synthesize frameBuffer;
@synthesize texture;
@synthesize colorBuffer;

- (id)initWithSize:(SIntSize)inSize
    {
    if ((self = [self init]) != NULL)
        {
		size = inSize;
		
		[self use];


//		// TODO check if depth buffer needed...
//		depthBuffer = [[CRenderBuffer alloc] init];
//		[depthBuffer storage:GL_DEPTH_COMPONENT16 size:size];
//		[frameBuffer attachObject:depthBuffer attachment:GL_DEPTH_ATTACHMENT];

//		colorBuffer = [[CRenderBuffer alloc] init];
//		[colorBuffer storage:GL_RGBA8_OES size:size];
//		[frameBuffer attachObject:colorBuffer attachment:GL_COLOR_ATTACHMENT0];

		[self frameBuffer];
        }
    return self;
    }

- (CFrameBuffer *)frameBuffer
	{
	if (frameBuffer == NULL)
		{
		frameBuffer = [[CFrameBuffer alloc] init];
		[frameBuffer bind];

		texture = [[CTexture alloc] initWithSize:size];
		[frameBuffer attachObject:texture attachment:GL_COLOR_ATTACHMENT0];

		GLenum theStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER); 
		if (theStatus != GL_FRAMEBUFFER_COMPLETE)
			{
			NSLog(@"glCheckFramebufferStatus failed: %@", NSStringFromGLenum(theStatus));
			}
		}
	return(frameBuffer);
	}

- (BOOL)start:(NSError **)outError
	{
	AssertOpenGLValidContext_();
	AssertOpenGLNoError_();

	// #########################################################################

	glViewport(0, 0, self.size.width, self.size.height);

    glDisable(GL_BLEND);

    glDisable(GL_DEPTH_TEST);

    glClearColor(255, 0, 255, 255);

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

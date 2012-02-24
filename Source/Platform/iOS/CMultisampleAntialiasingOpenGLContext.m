//
//  CMultisampleAntialiasingOpenGLContext.m
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/23/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CMultisampleAntialiasingOpenGLContext.h"

#import "CFrameBuffer.h"
#import "CRenderBuffer.h"

@interface CMultisampleAntialiasingOpenGLContext ()

@property (readwrite, nonatomic, strong) CFrameBuffer *multisampleFrameBuffer;
@property (readwrite, nonatomic, strong) CRenderBuffer *multisampleDepthBuffer;
@property (readwrite, nonatomic, strong) CRenderBuffer *multisampleColorBuffer;

@end

#pragma mark -

@implementation CMultisampleAntialiasingOpenGLContext

- (void)setup
	{
	self.multisampleFrameBuffer = [[CFrameBuffer alloc] init];
	[self.multisampleFrameBuffer bind];
	
	self.multisampleColorBuffer = [[CRenderBuffer alloc] init];
	[self.multisampleColorBuffer bind];
	glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, self.size.width, self.size.height);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.multisampleColorBuffer.name);

	self.multisampleDepthBuffer = [[CRenderBuffer alloc] init];
	[self.multisampleDepthBuffer bind];
	glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, self.size.width, self.size.height);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, self.multisampleDepthBuffer.name);


	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
		{
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		}
	}

- (void)present
	{
	glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, self.multisampleFrameBuffer.name);
	glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, self.frameBuffer.name);
	// Call a resolve to combine buffers
	glResolveMultisampleFramebufferAPPLE();
	// Present final image to screen

	// Discard frame buffers for extra performance: see http://www.khronos.org/registry/gles/extensions/EXT/EXT_discard_framebuffer.txt
	GLenum theAttachments[] = { GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT };
	glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, theAttachments);

	glBindRenderbuffer(GL_RENDERBUFFER, self.multisampleColorBuffer.name);
	[self.nativeContext presentRenderbuffer:GL_RENDERBUFFER];

	}

@end

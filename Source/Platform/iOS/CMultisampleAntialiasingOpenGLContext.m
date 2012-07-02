//
//  CMultisampleAntialiasingOpenGLContext.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 2/23/12.
//  Copyright 2012 Jonathan Wight. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Jonathan Wight.

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
	self.multisampleFrameBuffer = [[CFrameBuffer alloc] initWithTarget:GL_FRAMEBUFFER];
	self.multisampleFrameBuffer.label = [NSString stringWithFormat:@"Multisample framebuffer (%d)", self.frameBuffer.name];
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

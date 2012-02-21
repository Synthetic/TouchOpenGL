//
//  CTexture_Utilities.m
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CTexture_Utilities.h"

#import "CFrameBuffer.h"

@implementation CTexture (CTexture_Utilities)

- (CGImageRef)fetchImage
	{
	AssertOpenGLValidContext_();
	AssertOpenGLNoError_();

	// Store the current frame buffer...
	GLint theCurrentFrameBuffer = 0;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &theCurrentFrameBuffer);

	// Create a new frame buffer...
	CFrameBuffer *theFrameBuffer = [[CFrameBuffer alloc] init];
	[theFrameBuffer bind];

	// Attach the texture (self) to it.
	[theFrameBuffer attachTexture:self attachment:GL_COLOR_ATTACHMENT0];

	if (theFrameBuffer.isComplete == NO)
		{
		NSLog(@"Framebuffer not ready");
		return(NULL);
		}

	// GL read pixels from the frame buffer...
	CGImageRef theImage = [theFrameBuffer fetchImage:self.size];

	// Restore the old frame buffer...
    glBindFramebuffer(GL_FRAMEBUFFER, theCurrentFrameBuffer);

	AssertOpenGLNoError_();

	return(theImage);
	}

- (void)writeToFile:(NSString *)inPath
	{
	CGImageRef theImage = [self fetchImage];
	[UIImagePNGRepresentation([UIImage imageWithCGImage:theImage]) writeToFile:inPath atomically:YES];
	CFRelease(theImage);
	}

@end

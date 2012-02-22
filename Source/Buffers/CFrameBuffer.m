//
//  CFrameBuffer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 02/15/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
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
//  or implied, of toxicsoftware.com.

#import "CFrameBuffer.h"

#import "CRenderBuffer.h"
#import "CTexture.h"

@interface CFrameBuffer ()
@property (readwrite, nonatomic, strong) NSMutableArray *mutableAttachments;
@end

#pragma mark -

@implementation CFrameBuffer

@synthesize target;
@synthesize name;
@synthesize mutableAttachments;

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
		target = GL_FRAMEBUFFER;
        glGenFramebuffers(1, &name);
		AssertOpenGLNoError_();
		mutableAttachments = [NSMutableArray array];
		}
	return(self);
	}

- (id)initWithTarget:(GLenum)inTarget;
	{
	if ((self = [self init]) != NULL)
		{
		target = inTarget;
		}
	return(self);
	}

- (void)dealloc
    {
    if (glIsFramebuffer(name))
        {
        glDeleteFramebuffers(1, &name);
        name = 0;
        }
    }

- (NSArray *)attachments
	{
	return(self.mutableAttachments);
	}

- (BOOL)isComplete
    {
    NSAssert(glIsFramebuffer(name), @"name is not a framebuffer");
    GLenum theStatus = glCheckFramebufferStatus(self.target);
    return(theStatus == GL_FRAMEBUFFER_COMPLETE);
    }

- (void)bind
    {
    glBindFramebuffer(self.target, self.name);
    }

- (void)discard
	{
	#if TARGET_OS_IPHONE == 1
	
	GLenum theAttachments[ self.attachments.count ];
	int N = 0;
	for (id <COpenGLAsset> theAttachment in self.attachments)
		{
		theAttachments[N++] = theAttachment.name;
		}

	glDiscardFramebufferEXT(self.target, self.attachments.count, theAttachments);

	#else
	NSLog(@"No glDiscardFramebufferEXT on OSX");
	#endif
	}

- (void)attachObject:(id <COpenGLAsset>)inObject attachment:(GLenum)inAttachment
	{
	NSParameterAssert([self.mutableAttachments containsObject:inObject] == NO);
	
	[self.mutableAttachments addObject:inObject];
	
	if ([inObject isKindOfClass:[CTexture class]])
		{
			glFramebufferTexture2D(self.target, inAttachment, GL_TEXTURE_2D, inObject.name, 0);
		}
	else if ([inObject isKindOfClass:[CRenderBuffer class]])
		{
		glFramebufferRenderbuffer(self.target, inAttachment, GL_RENDERBUFFER, inObject.name);
		}

    AssertOpenGLNoError_();
	}

- (void)detachObject:(id <COpenGLAsset>)inObject attachment:(GLenum)inAttachment
	{
	NSParameterAssert([self.mutableAttachments containsObject:inObject] == YES);
	
	if ([inObject isKindOfClass:[CTexture class]])
		{
		glFramebufferTexture2D(self.target, inAttachment, GL_TEXTURE_2D, inObject.name, 0);
		}
	else if ([inObject isKindOfClass:[CRenderBuffer class]])
		{
		glFramebufferRenderbuffer(self.target, inAttachment, GL_RENDERBUFFER, 0);
		}
	
	[self.mutableAttachments removeObject:inObject];
	}
	
#pragma mark -

- (CGImageRef)fetchImage:(SIntSize)inSize CF_RETURNS_RETAINED
	{
	AssertOpenGLValidContext_();
	AssertOpenGLNoError_();
	
	NSMutableData *theData = [NSMutableData dataWithLength:inSize.width * 4 * inSize.height];

	GLint theReadFormat = GL_RGBA;
//	glGetIntegerv(GL_IMPLEMENTATION_COLOR_READ_FORMAT, &theReadFormat);
	GLint theReadType = GL_UNSIGNED_BYTE;
//	glGetIntegerv(GL_IMPLEMENTATION_COLOR_READ_TYPE, &theReadType);

	glReadPixels(0, 0, inSize.width, inSize.height, theReadFormat, theReadType, theData.mutableBytes);
//	AssertOpenGLNoError_();

	// #########################################################################
	
	CGColorSpaceRef theColorSpace = CGColorSpaceCreateDeviceRGB();
	
	const size_t width = inSize.width;
	const size_t height = inSize.height;
	const size_t bitsPerComponent = 8;
	const size_t bytesPerRow = width * (bitsPerComponent * 4) / 8;
	// TODO - probably dont want skip last
	CGBitmapInfo theBitmapInfo = kCGImageAlphaNoneSkipLast;
	
	CGContextRef theContext = CGBitmapContextCreateWithData(theData.mutableBytes, width, height, bitsPerComponent, bytesPerRow, theColorSpace, theBitmapInfo, NULL, NULL);
	
	CGImageRef theImage = CGBitmapContextCreateImage(theContext);
	
	// #########################################################################
	
	CFRelease(theContext);
	CFRelease(theColorSpace);

	return(theImage);		
	}

@end

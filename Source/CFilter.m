//
//  CFilter.m
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/21/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CFilter.h"

#import "CSceneRenderer_ImageExtensions.h"
#import "COpenGLContext.h"
#import "CCompositeTextureProgram.h"
#import "CProgram_Extensions.h"
#import "CVertexBufferReference_FactoryExtensions.h"
#import "COpenGLOffscreenContext.h"
#import "CFrameBuffer.h"
#import "CTexture_Utilities.h"
#import "CSourceCopyProgram.h"
#import "CSimpleTextureProgram.h"

@interface CFilter ()
@property (readwrite, nonatomic, assign) SIntSize size;
@property (readwrite, nonatomic, strong) COpenGLOffscreenContext *context;
@property (readwrite, nonatomic, strong) CTexture *a1_grain1;
@property (readwrite, nonatomic, strong) CTexture *a1_grain2;
@property (readwrite, nonatomic, strong) CTexture *a1_shift_warm;
@property (readwrite, nonatomic, strong) CSourceCopyProgram *program;

@property (readwrite, nonatomic, strong) CTexture *workingTexture;

@end

#pragma mark -

@implementation CFilter

- (id)initWithSize:(SIntSize)inSize;
    {
    if ((self = [super init]) != NULL)
        {
		_size = inSize;

		_context = [[COpenGLOffscreenContext alloc] initWithSize:_size];
		[_context use];

		glViewport(0, 0, self.size.width, self.size.height);

		glDisable(GL_BLEND);

		glDisable(GL_DEPTH_TEST);

		glClearColor(255, 0, 255, 255);
        }
    return self;
    }

#pragma mark -

- (void)start:(CTexture *)inStartTexture
	{
	[self.context use];

	// #########################################################################


	self.workingTexture = inStartTexture;

	}

- (void)filter:(void (^)(CTexture *texture))inFilter;
	{
	NSParameterAssert(inFilter != NULL);

	inFilter(self.workingTexture);
	
	self.workingTexture = [self.context detachTexture];
	}

- (CGImageRef)finish
	{
	return([self.workingTexture fetchImage]);
	}

@end

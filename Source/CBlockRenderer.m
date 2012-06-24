//
//  CBlockRenderer.m
//  VideoFilterToy_OSX
//
//  Created by Jonathan Wight on 3/2/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CBlockRenderer.h"

@implementation CBlockRenderer

@synthesize userInfo = _userInfo;
@synthesize setupBlock = _setupBlock;
@synthesize clearBlock = _clearBlock;
@synthesize prerenderBlock = _prerenderBlock;
@synthesize renderBlock = _renderBlock;
@synthesize postrenderBlock = _postrenderBlock;

- (void)setup
	{
	[super setup];
	
	if (self.setupBlock)
		{
        AssertOpenGLNoError_();

		self.setupBlock();

        AssertOpenGLNoError_();
		}
	}
	
- (void)clear
	{
	[super clear];

	if (self.clearBlock)
		{
        AssertOpenGLNoError_();

		self.clearBlock();

        AssertOpenGLNoError_();
		}
	}
	
- (void)prerender
	{
	[super prerender];

	if (self.prerenderBlock)
		{
        AssertOpenGLNoError_();

		self.prerenderBlock();

        AssertOpenGLNoError_();
		}
	}
	
- (void)render
	{
	[super render];

	if (self.renderBlock)
		{
        AssertOpenGLNoError_();

		self.renderBlock();

        AssertOpenGLNoError_();
		}
	}
	
- (void)postrender
	{
	[super postrender];

	if (self.postrenderBlock)
		{
        AssertOpenGLNoError_();

		self.postrenderBlock();

        AssertOpenGLNoError_();
		}
	}

@end

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
		self.setupBlock();
		}
	}
	
- (void)clear
	{
	[super clear];

	if (self.clearBlock)
		{
		self.clearBlock();
		}
	}
	
- (void)prerender
	{
	[super prerender];

	if (self.prerenderBlock)
		{
		self.prerenderBlock();
		}
	}
	
- (void)render
	{
	[super render];

	if (self.renderBlock)
		{
		self.renderBlock();
		}
	}
	
- (void)postrender
	{
	[super postrender];

	if (self.postrenderBlock)
		{
		self.postrenderBlock();
		}
	}

@end

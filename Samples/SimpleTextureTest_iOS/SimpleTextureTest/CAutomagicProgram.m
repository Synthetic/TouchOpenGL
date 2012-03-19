//
//  CAutomagicProgram.m
//  SimpleTextureTest
//
//  Created by Jonathan Wight on 3/18/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CAutomagicProgram.h"

@implementation CAutomagicProgram

- (NSArray *)updateBlocks
	{
	return(NULL);
	}
	
- (void)update
	{
	[super update];
	//
	for (id obj in self.updateBlocks)
		{
		void (^theBlock)(void) = obj;
		theBlock();
		}
	}

@end

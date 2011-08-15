//
//  CBlockRenderer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 02/15/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CBlockRenderer.h"


@implementation CBlockRenderer

@synthesize prerenderBlock;
@synthesize renderBlock;
@synthesize postrenderBlock;

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
		}
	return(self);
	}

- (void)prerender
    {
    [super prerender];
    //
    if (self.prerenderBlock)
        {
        self.prerenderBlock();
        }
    }

- (void)render
    {
    [super render];
    //
    if (self.renderBlock)
        {
        self.renderBlock();
        }
    }

- (void)postrender
    {
    [super postrender];
    //
    if (self.postrenderBlock)
        {
        self.postrenderBlock();
        }
    }

@end

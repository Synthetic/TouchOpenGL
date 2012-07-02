//
//  CBlockRenderer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 3/2/12.
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

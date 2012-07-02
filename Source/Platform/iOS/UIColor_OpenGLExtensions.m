//
//  NSColor_OpenGLExtensions.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 02/05/11.
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

#import "UIColor_OpenGLExtensions.h"

@implementation UIColor (UIColor_OpenGLExtensions)

- (Color4f)color4f
	{
    Color4f theColor;
    if ([self getRed:&theColor.r green:&theColor.g blue:&theColor.b alpha:&theColor.a] == NO)
        {
        NSAssert(NO, @"Could not get RGBA");
        }
	return(theColor);
	}
	
- (Color4ub)color4ub
	{
    Color4f theColor4f = self.color4f;
    
    Color4ub theColor = {
        .r = (GLubyte)(theColor4f.r * 255.0),
        .g = (GLubyte)(theColor4f.g * 255.0),
        .b = (GLubyte)(theColor4f.b * 255.0),
        .a = (GLubyte)(theColor4f.a * 255.0),
        };
    return(theColor);
	}

@end

//
//  NSColor_OpenGLExtensions.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 02/05/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

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
        .r = theColor4f.r * 255.0,
        .g = theColor4f.g * 255.0,
        .b = theColor4f.b * 255.0,
        .a = theColor4f.a * 255.0,
        };
    return(theColor);
	}

@end

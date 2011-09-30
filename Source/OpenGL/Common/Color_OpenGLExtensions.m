//
//  UIColor_OpenGLExtensions.m
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

#import "Color_OpenGLExtensions.h"

#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
@implementation UIColor (UIColor_OpenGLExtensions)
#elif TARGET_OS_MAC
@implementation NSColor (NSColor_OpenGLExtensions)
#endif

- (Color4f)color4f
	{
    Color4f theColor;
#if TARGET_OS_IPHONE
    CGColorRef theCGColor = self.CGColor;
    
    CGColorSpaceRef theColorSpace = CGColorGetColorSpace(theCGColor);
    CGColorSpaceModel theModel = CGColorSpaceGetModel(theColorSpace);
    BOOL isRGB = (theModel == kCGColorSpaceModelRGB);
    BOOL isMonochrome = (theModel == kCGColorSpaceModelMonochrome);
#elif TARGET_OS_MAC
    NSColorSpace *theColorSpace = [self colorSpace];
    NSColorSpaceModel theModel = [theColorSpace colorSpaceModel];
    BOOL isRGB = (theModel == NSRGBColorSpaceModel);
    BOOL isMonochrome = (theModel == NSGrayColorSpaceModel);
#endif
    if (isRGB)
        {
#if TARGET_OS_IPHONE
        const CGFloat *theComponents = CGColorGetComponents(theCGColor);
        theColor = (Color4f){ theComponents[0], theComponents[1], theComponents[2], CGColorGetAlpha(theCGColor)  };
#elif TARGET_OS_MAC
        CGFloat theComponents[4];
        [self getComponents:theComponents];
        theColor = (Color4f){ theComponents[0], theComponents[1], theComponents[2], [self alphaComponent] };
#endif
        }
    else if (isMonochrome)
        {
#if TARGET_OS_IPHONE
        const CGFloat *theComponents = CGColorGetComponents(theCGColor);
        theColor = (Color4f){ theComponents[0], theComponents[0], theComponents[0], CGColorGetAlpha(theCGColor)  };
#elif TARGET_OS_MAC
        CGFloat theComponents[2];
        [self getComponents:theComponents];
        theColor = (Color4f){ theComponents[0], theComponents[0], theComponents[0], [self alphaComponent] };
#endif
        }
    else
        {
        NSAssert(NO, @"Unknown color model");
        }
    return(theColor);
	}
	
- (Color4ub)color4ub
	{
    Color4f theColor4f = self.color4f;
	Color4ub theColor = { theColor4f.r * 255.0, theColor4f.g * 255.0, theColor4f.b * 255.0, theColor4f.a * 255.0 };
	return(theColor);
	}

@end

//
//  UIColor_PropertyListRepresentation.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/21/11.
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

#import "Color_PropertyListRepresentation.h"

#if TARGET_OS_IPHONE
@implementation UIColor (UIColor_PropertyListRepresentation)
#elif TARGET_OS_MAC
@implementation NSColor (NSColor_PropertyListRepresentation)
#endif

- (id)initWithPropertyListRepresentation:(id)inRepresentation error:(NSError **)outError;
    {
    #pragma unused (outError)
    
#if TARGET_OS_IPHONE
    CGFloat theAlpha = 1.0;
    
    NSArray *theComponents = NULL;
    if ([inRepresentation isKindOfClass:[NSArray class]])
        {
        theComponents = inRepresentation;
        }
    else if ([inRepresentation isKindOfClass:[NSString class]])
        {
        theComponents = [inRepresentation componentsSeparatedByString:@","];
        }
    else
        {
        NSAssert(NO, @"Can only handle arrays or strings.");
        }
    
    CGFloat theRed = [[theComponents objectAtIndex:0] floatValue];
    CGFloat theGreen = [[theComponents objectAtIndex:1] floatValue];
    CGFloat theBlue = [[theComponents objectAtIndex:2] floatValue];
    if ([theComponents count] == 4)
        {
        theAlpha = [[theComponents objectAtIndex:3] floatValue];
        }

	if ((self = [self initWithRed:theRed green:theGreen blue:theBlue alpha:theAlpha]) != NULL)
        {
		}
#elif TARGET_OS_MAC
    NSAssert(NO, @"TODO fix me");
#endif
	return(self);
	}


@end

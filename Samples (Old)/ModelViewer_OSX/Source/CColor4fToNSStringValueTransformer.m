//
//  CColor4fToNSStringValueTransformer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 05/03/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
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

#import "CColor4fToNSStringValueTransformer.h"

#import "Color_OpenGLExtensions.h"

@implementation CColor4fToNSStringValueTransformer

+ (void)load
    {
    @autoreleasepool
        {
        [self setValueTransformer:[[self alloc] init] forName:@"Color4fToNSStringValueTransformer"];
        }
    }

- (id)transformedValue:(id)value
    {
    Color4f theSourceColor;
    [value getValue:&theSourceColor];
    NSString *theString = [NSString stringWithFormat:@"%f %f %f %f", theSourceColor.r, theSourceColor.g, theSourceColor.b, theSourceColor.a];
    return(theString);
    }

- (id)reverseTransformedValue:(id)value
    {
    NSArray *theComponents = [value componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    Color4f theColor = {
        .r = [[theComponents objectAtIndex:0] doubleValue],
        .g = [[theComponents objectAtIndex:1] doubleValue],
        .b = [[theComponents objectAtIndex:2] doubleValue],
        .a = [[theComponents objectAtIndex:3] doubleValue],
        };

    NSValue *theValue = [NSValue valueWithBytes:&theColor objCType:@encode(Color4f)];
    return(theValue);
    }

@end

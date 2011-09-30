//
//  CDictionaryToVectorValueTransformer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/29/11.
//  Copyright 2011 Inkling. All rights reserved.
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
//  or implied, of Inkling.

#import "CDictionaryToVectorValueTransformer.h"

#import "OpenGLTypes.h"

@implementation CDictionaryToVectorValueTransformer

+ (void)load
    {
    NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];
    //
    [self setValueTransformer:[[[self alloc] init] autorelease] forName:@"DictionaryToVectorValueTransformer"];
    //
    [thePool drain];
    }

- (id)transformedValue:(id)value
    {
    Vector4 theSourceVector;
    [value getValue:&theSourceVector];
    NSDictionary *theDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithDouble:theSourceVector.x], @"x",
        [NSNumber numberWithDouble:theSourceVector.y], @"y",
        [NSNumber numberWithDouble:theSourceVector.z], @"z",
        [NSNumber numberWithDouble:theSourceVector.w], @"w",
        NULL];
    return(theDictionary);
    }

- (id)reverseTransformedValue:(id)value
    {
    Vector4 theVector = { 
        .x = [[value valueForKey:@"x"] doubleValue],
        .y = [[value valueForKey:@"y"] doubleValue],
        .z = [[value valueForKey:@"z"] doubleValue],
        .w = [[value valueForKey:@"w"] doubleValue],
        };
    return([NSValue valueWithBytes:&theVector objCType:@encode(Vector4)]);
    }

@end

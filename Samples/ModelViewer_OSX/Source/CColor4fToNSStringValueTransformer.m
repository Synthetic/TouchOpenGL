//
//  CColor4fToNSStringValueTransformer.m
//  ModelViewer_OSX
//
//  Created by Jonathan Wight on 05/03/11.
//  Copyright 2011 Inkling. All rights reserved.
//

#import "CColor4fToNSStringValueTransformer.h"

#import "Color_OpenGLExtensions.h"

@implementation CColor4fToNSStringValueTransformer

+ (void)load
    {
    NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];
    //
    [self setValueTransformer:[[[self alloc] init] autorelease] forName:@"Color4fToNSStringValueTransformer"];
    //
    [thePool drain];
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

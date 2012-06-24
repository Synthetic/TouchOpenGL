//
//  CDumper.h
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 6/24/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDumper : NSObject

- (void)incrementLevel;
- (void)decrememntLevel;
- (void)dump:(NSString *)inFormat, ...;
- (void)dump:(NSString *)inFormat argList:(va_list)inArgList;

@end

#pragma mark -

@protocol CDumping <NSObject>

- (void)dump:(CDumper *)inDumper;

@end

#pragma mark -

@interface NSObject (Dumping) <CDumping>

@end

#pragma mark -

@interface NSDictionary (Dumping) <CDumping>

@end
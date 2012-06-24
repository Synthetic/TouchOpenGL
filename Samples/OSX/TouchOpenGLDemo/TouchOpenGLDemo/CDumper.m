//
//  CDumper.m
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 6/24/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import "CDumper.h"

@interface CDumper ()
@property (readwrite, nonatomic, assign) NSUInteger level;
@end

@implementation CDumper

#if 0
+ (void)load
    {
    @autoreleasepool
        {
        NSDictionary *d = @{ @"hello" : @[@"world"] };
        CDumper *theDumper = [[CDumper alloc] init];
        [d dump:theDumper];

        NSLog(@"DONE");
        }
    }
#endif

- (void)incrementLevel
    {
    self.level++;
    }

- (void)decrememntLevel
    {
    NSParameterAssert(self.level > 0);
    self.level--;
    }

- (void)dump:(NSString *)inFormat, ...
    {
    va_list theArgList;
    va_start(theArgList, inFormat);
    [self dump:inFormat argList:theArgList];
    va_end(theArgList);
    }

- (void)dump:(NSString *)inFormat argList:(va_list)inArgList
    {
    NSString *theString = [[NSString alloc] initWithFormat:inFormat arguments:inArgList];
    NSLog(@"%@", theString);
    }

@end

#pragma mark -

@implementation NSObject (Dumping)

- (void)dump:(CDumper *)inDumper;
    {
    [inDumper dump:[self description]];
    }

@end

#pragma mark -

@implementation NSDictionary (Dumping)

- (void)dump:(CDumper *)inDumper;
    {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [inDumper dump:@"%@: %@", key, obj];
        }];
    }

@end
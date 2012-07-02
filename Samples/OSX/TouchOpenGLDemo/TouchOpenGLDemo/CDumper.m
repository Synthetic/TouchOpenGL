//
//  CDumper.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 6/24/12.
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
//
//  CSimplePreprocessor.h
//  Preprocessor
//
//  Created by Jonathan Wight on 2/22/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSimplePreprocessor : NSObject

@property (readwrite, nonatomic, copy) NSString *(^loader)(NSString *name);

- (NSString *)preprocess:(NSString *)inSource error:(NSError **)outError;

@end

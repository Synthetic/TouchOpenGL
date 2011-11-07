//
//  CMTLParser.h
//  ModelViewer_OSX
//
//  Created by Jonathan Wight on 8/30/11.
//  Copyright (c) 2011 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMTLParser : NSObject

@property (readonly, nonatomic, strong) NSURL *URL;
@property (readonly, nonatomic, strong) NSDictionary *materials;

- (id)initWithURL:(NSURL *)inURL;

- (BOOL)parse:(NSError **)outError;

@end

//
//  CMTLParser.h
//  ModelViewer_OSX
//
//  Created by Jonathan Wight on 8/30/11.
//  Copyright (c) 2011 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMTLParser : NSObject

@property (readonly, nonatomic, retain) NSURL *URL;
@property (readonly, nonatomic, retain) NSDictionary *materials;

- (id)initWithURL:(NSURL *)inURL;

- (BOOL)parse:(NSError **)outError;

@end

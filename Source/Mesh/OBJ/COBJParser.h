//
//  COBJParser.h
//  ModelViewer_OSX
//
//  Created by Jonathan Wight on 8/30/11.
//  Copyright (c) 2011 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMesh;

@interface COBJParser : NSObject

@property (readonly, nonatomic, retain) NSURL *URL;
@property (readonly, nonatomic, retain) CMesh *mesh;

- (id)initWithURL:(NSURL *)inURL;

- (BOOL)parse:(NSError **)outError;

@end

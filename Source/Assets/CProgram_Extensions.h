//
//  CProgram_Extensions.h
//  OpenGLTest
//
//  Created by Jonathan Wight on 9/11/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CProgram.h"

@interface CProgram (Extensions)

- (id)initWithName:(NSString *)inName attributeNames:(NSArray *)inAttributeNames uniformNames:(NSArray *)inUniformNames;
- (id)initWithURL:(NSURL *)inURL;

@end

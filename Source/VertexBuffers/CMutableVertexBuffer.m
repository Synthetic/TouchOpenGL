//
//  CMutableVertexBuffer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/08/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CMutableVertexBuffer.h"

@implementation CMutableVertexBuffer

- (NSMutableData *)mutableData
    {
    // TODO use assert cast
    // TODO dont do this. Use a real mutableData property.
    return((NSMutableData *)self.data);
    }

- (void)update:(NSRange)inRange
    {
    glBindBuffer(self.target, self.name);
    glBufferSubData(self.target, inRange.location, inRange.length, [self.mutableData mutableBytes]);
    }

- (void)update;
    {
    glBindBuffer(self.target, self.name);
    glBufferSubData(self.target, 0, [self.mutableData length], [self.mutableData mutableBytes]);
    }

@end

//
//  COffscreenOpenGLContext.h
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 6/28/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import "COpenGLContext.h"

#import "OpenGLTypes.h"

@interface COffscreenOpenGLContext : COpenGLContext

@property (readonly, nonatomic, assign) SIntSize size;

- (id)initWithSize:(SIntSize)inSize;

@end

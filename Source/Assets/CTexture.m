//
//  CTexture.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/06/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CTexture.h"

@interface CTexture ()
@property (readwrite, nonatomic, assign) BOOL named;
@end

@implementation CTexture

@synthesize name;
@synthesize size;
@synthesize internalFormat;
@synthesize hasAlpha;

@synthesize named;

- (id)initWithName:(GLuint)inName size:(SIntSize)inSize
    {
    if ((self = [super init]) != NULL)
        {
        name = inName;
        size = inSize;
        named = YES;
        }
    return(self);
    }

- (void)dealloc
    {
    if (named == YES && glIsTexture(name))
        {
        glDeleteTextures(1, &name);
        name = 0;
        }
    }

- (BOOL)isValid
    {
    return(glIsTexture(self.name));
    }
    
@end

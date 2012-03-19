//
//  CTextureUnit.m
//  SimpleTextureTest
//
//  Created by Jonathan Wight on 3/19/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CTextureUnit.h"

#import "CTexture.h"

@implementation CTextureUnit

- (id)initWithIndex:(GLuint)inIndex
    {
    if ((self = [super init]) != NULL)
        {
        _index = inIndex;
        }
    return self;
    }

- (void)use:(GLuint)inUniform;
	{
	glActiveTexture(GL_TEXTURE0 + _index);
	[self.texture bind];
	glUniform1i(inUniform, _index);
	}

@end

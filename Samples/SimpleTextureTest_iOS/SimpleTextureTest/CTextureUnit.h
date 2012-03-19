//
//  CTextureUnit.h
//  SimpleTextureTest
//
//  Created by Jonathan Wight on 3/19/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTexture;

@interface CTextureUnit : NSObject

@property (readwrite, nonatomic, strong) CTexture *texture;
@property (readonly, nonatomic, assign) GLuint index;

- (id)initWithIndex:(GLuint)inIndex;

- (void)use:(GLuint)inUniform;

@end

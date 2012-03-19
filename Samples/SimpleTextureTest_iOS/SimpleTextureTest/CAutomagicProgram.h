//
//  CAutomagicProgram.h
//  SimpleTextureTest
//
//  Created by Jonathan Wight on 3/18/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CProgram.h"

typedef void (^ProgramUpdateBlock)(void);

@interface CAutomagicProgram : CProgram

@property (readonly, nonatomic, strong) NSArray *updateBlocks;

@end

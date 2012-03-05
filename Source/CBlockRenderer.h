//
//  CBlockRenderer.h
//  VideoFilterToy_OSX
//
//  Created by Jonathan Wight on 3/2/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CSceneRenderer.h"

@interface CBlockRenderer : CSceneRenderer

@property (readwrite, nonatomic, strong) id userInfo;

@property (readwrite, nonatomic, copy) void (^setupBlock)(void);
@property (readwrite, nonatomic, copy) void (^clearBlock)(void);
@property (readwrite, nonatomic, copy) void (^prerenderBlock)(void);
@property (readwrite, nonatomic, copy) void (^renderBlock)(void);
@property (readwrite, nonatomic, copy) void (^postrenderBlock)(void);

@end

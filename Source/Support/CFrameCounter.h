//
//  CFrameCounter.h
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 7/5/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFrameCounter : NSObject

@property (readonly, nonatomic, assign) BOOL started;
@property (readonly, nonatomic, assign) NSUInteger frameCount; // Observable.
@property (readonly, nonatomic, assign) CFTimeInterval previousFrameDuration;
@property (readonly, nonatomic, assign) CFTimeInterval currentFrameDuration;
@property (readonly, nonatomic, assign) double framesPerSecond; // Observable.
@property (readonly, nonatomic, assign) double weight;

- (void)start;
- (void)stop;
- (void)incrementFrameCount;

@end

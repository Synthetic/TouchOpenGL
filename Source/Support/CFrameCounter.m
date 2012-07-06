//
//  CFrameCounter.m
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 7/5/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import "CFrameCounter.h"

@interface CFrameCounter ()
@property (readwrite, nonatomic, assign) NSUInteger frameCount;
@property (readwrite, nonatomic, assign) CFTimeInterval startAbsoluteTime;
@property (readwrite, nonatomic, assign) CFTimeInterval stopAbsoluteTime;
@property (readwrite, nonatomic, assign) CFTimeInterval previousFrameAbsoluteTime;
@property (readwrite, nonatomic, assign) CFTimeInterval currentAbsoluteTime;
@end

#pragma mark 0

@implementation CFrameCounter

+ (NSSet *)keyPathsForValuesAffectingFramesPerSecond
    {
    return([NSSet setWithObject:@"frameCount"]);
    }

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        _weight = 0.1;
        }
    return self;
    }

- (NSString *)description
    {
    NSArray *theComponents = @[
        [NSString stringWithFormat:@"started: %@", self.started ? @"YES" : @"NO"],
        [NSString stringWithFormat:@"frame count: %ld", self.frameCount],
        [NSString stringWithFormat:@"Δ (previous): %0.3f", self.previousFrameDuration],
        [NSString stringWithFormat:@"Δ (current): %0.3f", self.currentFrameDuration],
        [NSString stringWithFormat:@"fps: %0.3f", self.framesPerSecond],
        ];

    return([NSString stringWithFormat:@"%@ (%@)", [super description], [theComponents componentsJoinedByString:@", "]]);
    }

- (double)framesPerSecond
    {
    return(_currentFrameDuration != 0.0 ? 1.0 / _currentFrameDuration : INFINITY);
    }

- (void)start
    {
    if (_started == NO)
        {
        _frameCount = 0;
        _startAbsoluteTime = isnormal(_currentAbsoluteTime) ? _currentAbsoluteTime : CFAbsoluteTimeGetCurrent();
        _stopAbsoluteTime = NAN;
        _previousFrameAbsoluteTime = _startAbsoluteTime;
        _started = YES;
        }
    }

- (void)stop
    {
    if (_started == YES)
        {
        _stopAbsoluteTime = CFAbsoluteTimeGetCurrent();
        _started = NO;
        }
    }

- (void)incrementFrameCount
    {
    _currentAbsoluteTime = CFAbsoluteTimeGetCurrent();

    if (_started == NO)
        {
        [self start];
        }

    NSParameterAssert(self.started == YES);

    _previousFrameDuration = _currentFrameDuration;
    if (_previousFrameDuration != 0.0)
        {
        _currentFrameDuration = _weight * (_currentAbsoluteTime - _previousFrameAbsoluteTime) + (1.0 - _weight) * _previousFrameDuration;
        }
    else
        {
        _currentFrameDuration = _currentAbsoluteTime - _previousFrameAbsoluteTime;
        }

    self.frameCount++;

    _previousFrameAbsoluteTime = _currentAbsoluteTime;
    }


@end

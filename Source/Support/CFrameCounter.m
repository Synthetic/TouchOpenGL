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

+ (NSSet *)keyPathsForValuesAffectingSmoothedFramesPerSecond
    {
    return([NSSet setWithObject:@"frameCount"]);
    }

- (NSString *)description
    {
    NSArray *theComponents = @[
        [NSString stringWithFormat:@"frame count: %ld", self.frameCount],
        [NSString stringWithFormat:@"Δ (previous): %0.3f", self.previousFrameDuration],
        [NSString stringWithFormat:@"Δ (current): %0.3f", self.currentFrameDuration],
        [NSString stringWithFormat:@"Δ (smoothed): %0.3f", self.smoothedFrameDuration],
        [NSString stringWithFormat:@"fps: %0.3f", self.framesPerSecond],
        [NSString stringWithFormat:@"fps (smoothed): %0.3f", self.smoothedFramesPerSecond],
        ];

    return([NSString stringWithFormat:@"%@ (%@)", [super description], [theComponents componentsJoinedByString:@", "]]);
    }

- (double)framesPerSecond
    {
    return(_currentFrameDuration != 0.0 ? 1.0 / _currentFrameDuration : INFINITY);
    }

- (double)smoothedFramesPerSecond
    {
    const CFTimeInterval theSmoothedFrameDuration = self.smoothedFrameDuration;
    return(theSmoothedFrameDuration != 0.0 ? 1.0 / self.smoothedFrameDuration : INFINITY);
    }

- (CFTimeInterval)smoothedFrameDuration
    {
    if (_previousFrameDuration > 0.0)
        {
        return(0.1 * _currentFrameDuration + 0.9 * _previousFrameDuration);
        }
    else
        {
        return(_currentFrameDuration);
        }
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
    _currentFrameDuration = _currentAbsoluteTime - _previousFrameAbsoluteTime;
    self.frameCount++;

    _previousFrameAbsoluteTime = _currentAbsoluteTime;
    }


@end

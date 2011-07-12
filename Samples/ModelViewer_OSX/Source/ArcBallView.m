//
//  ArcBallView.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 04/26/11.
//  Copyright 2011 Inkling. All rights reserved.
//

#import "ArcBallView.h"

#import "CArcBall.h"
#import "CModelDocument.h"

@implementation ArcBallView

@synthesize arcBall = _arcBall;
@synthesize startPoint = _startPoint;
@synthesize startQuaternion = _startQuaternion;
@synthesize document = _document;

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        _arcBall = [[CArcBall alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_arcBall release];
    [super dealloc];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    _startPoint = [self convertPointFromBase:[theEvent locationInWindow]];
    _startQuaternion = QuaternionSetEuler(_document.yaw * M_PI / 180.0f, _document.pitch * M_PI / 180.0f, _document.roll * M_PI / 180.0f);
    [_arcBall start:CGPointZero];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    CGRect selfBounds = [self bounds];
    CGPoint newPoint = [self convertPointFromBase:[theEvent locationInWindow]];
    CGFloat dx = (_startPoint.x - newPoint.x) / selfBounds.size.width;
    CGFloat dy = (_startPoint.y - newPoint.y) / selfBounds.size.height;
    [_arcBall dragTo:CGPointMake(dx, dy)];

    GLfloat yaw, pitch, roll;
    Quaternion q = QuaternionMultiply(_startQuaternion, _arcBall.rotation);
    QuaternionGetEuler(q, &yaw, &pitch, &roll);
    [_document setYaw:yaw * 180.0f / M_PI];
    [_document setPitch:pitch * 180.0f / M_PI];
    [_document setRoll:roll * 180.0f / M_PI];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    const GLfloat kMinScale = 0.2f;
    const GLfloat kMaxScale = 5.0f;
    const GLfloat currentScale = [_document scale];
    const CGFloat deltaY = [theEvent deltaY];
    const CGFloat newScale = MAX(MIN(currentScale + deltaY, kMaxScale), kMinScale);
    [_document setScale:newScale];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end

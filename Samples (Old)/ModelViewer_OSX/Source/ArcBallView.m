//
//  ArcBallView.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 04/26/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Jonathan Wight.

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

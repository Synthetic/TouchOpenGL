//
//  CInteractiveRendererView.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/09/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
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
//  or implied, of toxicsoftware.com.

#import "CInteractiveRendererView.h"

#import <CoreMotion/CoreMotion.h>

#import "OpenGLTypes.h"
#import "CArcBall.h"
#import "Quaternion.h"
#import "COBJRenderer.h"

@interface CInteractiveRendererView ()
@property (readwrite, nonatomic, retain) CArcBall *arcBall;
@property (readwrite, nonatomic, assign) CGPoint arcBallCenter;
#if ENABLE_MOTION_ROTATION
@property (readwrite, nonatomic, retain) CMMotionManager *motionManager;
#endif

- (void)pinch:(UIPinchGestureRecognizer *)inGestureRecognizer;
- (void)pan:(UIPanGestureRecognizer *)inGestureRecognizer;
@end

@implementation CInteractiveRendererView

@synthesize gestureRotation;
@synthesize savedRotation;
@synthesize scale;
@synthesize rotationAxis;
@synthesize arcBall;
@synthesize arcBallCenter;
#if ENABLE_MOTION_ROTATION
@synthesize motionRotation;
@synthesize motionManager;
#endif

- (id)initWithFrame:(CGRect)inFrame;
    {    
    if ((self = [super initWithFrame:inFrame]))
        {
        
        arcBall = [[CArcBall alloc] init];
        
        scale = 1.0;
        
        UIPinchGestureRecognizer *thePinchGestureRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)] autorelease];
        [self addGestureRecognizer:thePinchGestureRecognizer];

        UIPanGestureRecognizer *thePanGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)] autorelease];
        [self addGestureRecognizer:thePanGestureRecognizer];

#if ENABLE_MOTION_ROTATION
        motionManager = [[CMMotionManager alloc] init];
        [motionManager startDeviceMotionUpdates];
#endif

        savedRotation = QuaternionIdentity;
        }

    return self;
    }
    
- (id)initWithCoder:(NSCoder *)inDecoder
    {    
    if ((self = [super initWithCoder:inDecoder]) != NULL)
        {

        arcBall = [[CArcBall alloc] init];
        
        scale = 1.0;
        
        UIPinchGestureRecognizer *thePinchGestureRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)] autorelease];
        [self addGestureRecognizer:thePinchGestureRecognizer];

        UIPanGestureRecognizer *thePanGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)] autorelease];
        [self addGestureRecognizer:thePanGestureRecognizer];

#if ENABLE_MOTION_ROTATION
        motionManager = [[CMMotionManager alloc] init];
        [motionManager startDeviceMotionUpdates];
#endif

        savedRotation = QuaternionIdentity;
        }

    return self;
    }

- (void)dealloc
    {
    [arcBall release];
    arcBall = NULL;

#if ENABLE_MOTION_ROTATION
    [motionManager release];
    motionManager = NULL;
#endif
    //
    [super dealloc];
    }

- (void)render
    {
#if ENABLE_MOTION_ROTATION
    CMDeviceMotion *theDeviceMotion = self.motionManager.deviceMotion;
    CMQuaternion theCMRotation = theDeviceMotion.attitude.quaternion;
    self.motionRotation = (Quaternion){ theCMRotation.x, theCMRotation.y, theCMRotation.z, theCMRotation.w };
#endif

    Matrix4 theTransform = Matrix4MakeScale(self.scale, self.scale, self.scale);

#if ENABLE_MOTION_ROTATION
    theTransform = Matrix4Concat(Matrix4FromQuaternion(self.motionRotation), theTransform);
#endif
    theTransform = Matrix4Concat(Matrix4FromQuaternion(self.gestureRotation), theTransform);
    
    ((COBJRenderer *)self.renderer).modelTransform = theTransform;
    
    [super render];
    }



- (void)pinch:(UIPinchGestureRecognizer *)inGestureRecognizer
    {
    self.scale += inGestureRecognizer.velocity / 10;
    self.scale = MAX(self.scale, 0.01);
    }

- (void)pan:(UIPanGestureRecognizer *)inGestureRecognizer
    {
    CGSize theSize = self.bounds.size;
    CGPoint theLocation = [inGestureRecognizer locationInView:self];

    CGPoint thePoint = {
        .x = theLocation.x / theSize.width - 0.5f,
        .y = (theLocation.y / theSize.height - 0.5f) * -1.0,
        };

    if (inGestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
        self.arcBallCenter = thePoint;
        [self.arcBall start:CGPointZero];
        
//        self,transgo
        }
    else if (inGestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
        CGPoint center = self.arcBallCenter;
        CGPoint relativePoint = CGPointMake(center.x - thePoint.x, center.y - thePoint.y);
        [self.arcBall dragTo:relativePoint];
        
        self.gestureRotation = QuaternionConstrainedToAxis(QuaternionMultiply(self.savedRotation, self.arcBall.rotation), self.rotationAxis);
        }
    else if (inGestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
        self.savedRotation = self.gestureRotation;
        }
    }

@end

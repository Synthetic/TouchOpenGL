//
//  CInteractiveRendererView.m
//  ModelViewer
//
//  Created by Jonathan Wight on 03/09/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

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
@synthesize scaleMin;
@synthesize scaleMax;
@synthesize rollMin;
@synthesize rollMax;
@synthesize pitchMin;
@synthesize pitchMax;
@synthesize yawMin;
@synthesize yawMax;
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
        
        scale = 0.001;
        scaleMin = -CGFLOAT_MIN;
        scaleMax = CGFLOAT_MAX;
        rollMin = -CGFLOAT_MAX;
        rollMax = CGFLOAT_MAX;
        pitchMin = -CGFLOAT_MAX; // DegreesToRadians(-90);
        pitchMax = CGFLOAT_MAX; // DegreesToRadians(0);
        yawMin = -CGFLOAT_MAX;
        yawMax = CGFLOAT_MAX;
        
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
        
        scale = 0.001;
        scaleMin = CGFLOAT_MIN;
        scaleMax = CGFLOAT_MAX;
        
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
    Quaternion theRotation = self.gestureRotation;
    
    GLfloat theRoll, thePitch, theYaw;
    
    QuaternionGetEuler(theRotation, &theYaw, &thePitch, &theRoll);
    theYaw = MIN(MAX(theYaw, yawMin), yawMax);
    thePitch = MIN(MAX(thePitch, pitchMin), pitchMax);
    theRoll = MIN(MAX(theRoll, rollMin), rollMax);
    theRotation = QuaternionSetEuler(theYaw, thePitch, theRoll);
    


    theTransform = Matrix4Concat(Matrix4FromQuaternion(theRotation), theTransform);
    

    
    
    ((COBJRenderer *)self.renderer).modelTransform = theTransform;
    
    [super render];
    }



- (void)pinch:(UIPinchGestureRecognizer *)inGestureRecognizer
    {
    self.scale += inGestureRecognizer.velocity / 10;
    self.scale = MIN(MAX(self.scale, self.scaleMin), self.scaleMax);
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

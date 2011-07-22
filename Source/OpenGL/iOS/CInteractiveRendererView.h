//
//  CInteractiveRendererView.h
//  ModelViewer
//
//  Created by Jonathan Wight on 03/09/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CRendererView.h"

#import "Quaternion.h"

#define ENABLE_MOTION_ROTATION 0

@interface CInteractiveRendererView : CRendererView {
    
}

#if ENABLE_MOTION_ROTATION
@property (readwrite, nonatomic, assign) Quaternion motionRotation;
#endif
@property (readwrite, nonatomic, assign) Quaternion gestureRotation;
@property (readwrite, nonatomic, assign) Quaternion savedRotation;
@property (readwrite, nonatomic, assign) CGFloat scale;
@property (readwrite, nonatomic, assign) CGFloat scaleMin;
@property (readwrite, nonatomic, assign) CGFloat scaleMax;
@property (readwrite, nonatomic, assign) Vector3 rotationAxis; // If not set, rotation is free

@end

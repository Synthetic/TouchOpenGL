//
//  ArcBallView.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 04/26/11.
//  Copyright 2011 Inkling. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CArcBall;
@class CModelDocument;

#import "OpenGLTypes.h"
#import "Quaternion.h"

@interface ArcBallView : NSView
@property (nonatomic, strong) CArcBall *arcBall;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) Quaternion startQuaternion;
@property (nonatomic, unsafe_unretained) CModelDocument *document; // TODO -- hack!
@end

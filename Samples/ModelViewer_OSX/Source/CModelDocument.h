//
//  PopTipDocument.h
//  TouchOpenGL
//
//  Created by Aaron Golden on 3/21/11.
//  Copyright 2011 Inkling. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class COBJRenderer;
@class CRendererView;

@interface CModelDocument : NSDocument {
}

@property (nonatomic, strong) COBJRenderer *renderer;
@property (nonatomic, strong) IBOutlet CRendererView *mainView;

@property (nonatomic, assign) GLfloat roll;
@property (nonatomic, assign) GLfloat pitch;
@property (nonatomic, assign) GLfloat yaw;
@property (nonatomic, assign) GLfloat scale;

@property (nonatomic, assign) GLfloat cameraX;
@property (nonatomic, assign) GLfloat cameraY;
@property (nonatomic, assign) GLfloat cameraZ;

@property (nonatomic, assign) GLfloat lightX;
@property (nonatomic, assign) GLfloat lightY;
@property (nonatomic, assign) GLfloat lightZ;

@property (nonatomic, strong) NSArray *programs;
@property (nonatomic, strong) NSString *defaultProgram;

@property (readwrite, nonatomic, strong) NSArray *materials;


@end

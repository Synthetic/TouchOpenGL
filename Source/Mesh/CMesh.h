//
//  CNewMesh.h
//  ModelViewer
//
//  Created by Jonathan Wight on 03/22/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpenGLTypes.h"
#import "Matrix.h"

@interface CMesh : NSObject <NSCopying> {
    
}

@property (readonly, nonatomic, retain) NSArray *geometries;
@property (readonly, nonatomic, assign) Vector3 center; // in model space
@property (readonly, nonatomic, assign) Vector3 p1, p2; // in model space
@property (readonly, nonatomic, assign) Matrix4 transform;
@property (readonly, nonatomic, assign) BOOL cullBackFaces;
@property (readonly, nonatomic, assign) NSString *programName;

@end

#pragma mark -

@interface CMutableMesh : CMesh <NSMutableCopying> {
    
}

@property (readwrite, nonatomic, retain) NSArray *geometries;
@property (readwrite, nonatomic, assign) Vector3 center; // in model space
@property (readwrite, nonatomic, assign) Vector3 p1, p2; // in model space
@property (readwrite, nonatomic, assign) Matrix4 transform;
@property (readwrite, nonatomic, assign) BOOL cullBackFaces;
@property (readwrite, nonatomic, assign) NSString *programName;

@end

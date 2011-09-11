//
//  CNewMesh.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/22/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CMesh.h"

@interface CMesh ()
@property (readwrite, nonatomic, strong) NSArray *geometries;
@property (readwrite, nonatomic, assign) Vector3 center; // in model space
@property (readwrite, nonatomic, assign) Vector3 p1, p2; // in model space
@property (readwrite, nonatomic, assign) Matrix4 transform;
@property (readwrite, nonatomic, assign) BOOL cullBackFaces;
@property (readwrite, nonatomic, strong) NSString *programName;
@end

#pragma mark -

@implementation CMesh

@synthesize geometries;
@synthesize center;
@synthesize p1, p2;
@synthesize transform;
@synthesize cullBackFaces;
@synthesize programName;

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        transform = Matrix4Identity;
        cullBackFaces = NO;
		}
	return(self);
	}


- (id)copyWithZone:(NSZone *)zone;
    {
    #pragma unused (zone)
    
    CMesh *theCopy = [[CMesh alloc] init];
    theCopy.geometries = self.geometries;
    theCopy.center = self.center;
    theCopy.p1 = self.p1;
    theCopy.p2 = self.p2;
    theCopy.cullBackFaces = self.cullBackFaces;
    theCopy.programName = self.programName;

    return(theCopy);
    }

@end

#pragma mark -

@implementation CMutableMesh

@dynamic geometries;
@dynamic center;
@dynamic p1, p2;
@dynamic transform;
@dynamic cullBackFaces;
@dynamic programName;

- (id)mutableCopyWithZone:(NSZone *)zone;
    {
    #pragma unused (zone)
    
    CMutableMesh *theCopy = [[CMutableMesh alloc] init];
    theCopy.geometries = self.geometries;
    theCopy.center = self.center;
    theCopy.p1 = self.p1;
    theCopy.p2 = self.p2;
    theCopy.cullBackFaces = self.cullBackFaces;
    theCopy.programName = self.programName;

    return(theCopy);
    }

@end

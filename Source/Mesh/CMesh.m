//
//  CNewMesh.m
//  ModelViewer
//
//  Created by Jonathan Wight on 03/22/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CMesh.h"


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
        programName = [@"Lighting_PerVertex" retain];
		}
	return(self);
	}


- (void)dealloc
    {
    [geometries release];
    geometries = NULL;
    //
    [programName release];
    programName = NULL;
    //
    [super dealloc];
    }

@end

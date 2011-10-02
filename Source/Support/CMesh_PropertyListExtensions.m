//
//  CMesh+PropertyListExtensions.m
//  ModelViewer_OSX
//
//  Created by Jonathan Wight on 8/30/11.
//  Copyright (c) 2011 Jonathan Wight. All rights reserved.
//

#import "CMesh_PropertyListExtensions.h"

#import "CGeometry.h"
#import "CGeometry_PropertyListExtensions.h"

@implementation CMesh (PropertyListExtensions)

- (id)asPropertyList
    {
    NSMutableDictionary *theMeshDictionary = [NSMutableDictionary dictionary];
    
    if (self.programName)
        {
        [theMeshDictionary setObject:self.programName forKey:@"programName"];
        }
    
    NSMutableArray *theGeometryDictionaries = [NSMutableArray array];
    for (CGeometry *theGeometry in self.geometries)
        {
        NSDictionary *theGeometryDictionary = [theGeometry asPropertyList];
        [theGeometryDictionaries addObject:theGeometryDictionary];
        }
    [theMeshDictionary setObject:theGeometryDictionaries forKey:@"geometries"];
    
    
//@property (readonly, nonatomic, strong) NSArray *geometries;
//@property (readonly, nonatomic, assign) Vector3 center; // in model space
//@property (readonly, nonatomic, assign) Vector3 p1, p2; // in model space
//@property (readonly, nonatomic, assign) Matrix4 transform;
//@property (readonly, nonatomic, assign) BOOL cullBackFaces;
//@property (readonly, nonatomic, strong) NSString *programName;
    
    
    
    
    
    return(theMeshDictionary);
    }

@end

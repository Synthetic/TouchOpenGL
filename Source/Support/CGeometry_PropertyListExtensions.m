//
//  CGeometry+PropertyListExtensions.m
//  ModelViewer_OSX
//
//  Created by Jonathan Wight on 8/30/11.
//  Copyright (c) 2011 Jonathan Wight. All rights reserved.
//

#import "CGeometry_PropertyListExtensions.h"

#import "CMaterial.h"
#import "CVertexBufferReference.h"
#import "CVertexArrayBuffer.h"

@implementation CGeometry (PropertyListExtensions)

- (id)asPropertyList
    {
    NSMutableDictionary *theGeometryDictionary = [NSMutableDictionary dictionary];
    
    if (self.material)
        {
        [theGeometryDictionary setObject:self.material.name forKey:@"materialName"];
        }











//@property (readwrite, nonatomic, strong) CVertexBufferReference *indices;
//@property (readwrite, nonatomic, strong) CVertexBufferReference *positions;
//@property (readwrite, nonatomic, strong) CVertexBufferReference *texCoords;
//@property (readwrite, nonatomic, strong) CVertexBufferReference *normals;
//
//@property (readwrite, nonatomic, strong) CMaterial *material;

    return(theGeometryDictionary);
    }

@end

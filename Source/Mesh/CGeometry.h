//
//  CGeometry.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/22/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CVertexArrayBuffer;
@class CVertexBufferReference;
@class CMaterial;

@interface CGeometry : NSObject {
    
}

@property (readwrite, nonatomic, strong) CVertexArrayBuffer *vertexArrayBuffer;

@property (readwrite, nonatomic, strong) CVertexBufferReference *indices;
@property (readwrite, nonatomic, strong) CVertexBufferReference *positions;
@property (readwrite, nonatomic, strong) CVertexBufferReference *texCoords;
@property (readwrite, nonatomic, strong) CVertexBufferReference *normals;

@property (readwrite, nonatomic, strong) CMaterial *material;

@end

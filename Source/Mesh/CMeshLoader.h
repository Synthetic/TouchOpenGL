//
//  CNewModelLoader.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/22/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMesh;

@interface CMeshLoader : NSObject {
    
}

@property (readonly, nonatomic, strong) CMesh *mesh;
@property (readonly, nonatomic, strong) NSMutableDictionary *materials;

- (BOOL)loadMeshWithURL:(NSURL *)inURL error:(NSError **)outError;

@end

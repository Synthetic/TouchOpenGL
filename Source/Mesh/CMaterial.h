//
//  CMaterial.h
//  ModelViewer
//
//  Created by Jonathan Wight on 03/17/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpenGLTypes.h"

@class CTexture;

@interface CMaterial : NSObject <NSCopying> {
    
}

@property (readonly, nonatomic, retain) NSString *name;
@property (readonly, nonatomic, assign) Color4f ambientColor;
@property (readonly, nonatomic, assign) Color4f diffuseColor;
@property (readonly, nonatomic, assign) Color4f specularColor;
@property (readonly, nonatomic, assign) GLfloat shininess;
@property (readonly, nonatomic, assign) GLfloat alpha;

@property (readonly, nonatomic, retain) CTexture *texture;

@end

#pragma mark -

@interface CMutableMaterial : CMaterial <NSMutableCopying> {

}

@property (readwrite, nonatomic, retain) NSString *name;
@property (readwrite, nonatomic, assign) Color4f ambientColor;
@property (readwrite, nonatomic, assign) Color4f diffuseColor;
@property (readwrite, nonatomic, assign) Color4f specularColor;
@property (readwrite, nonatomic, assign) GLfloat shininess;
@property (readwrite, nonatomic, assign) GLfloat alpha;

@property (readwrite, nonatomic, retain) CTexture *texture;

@end
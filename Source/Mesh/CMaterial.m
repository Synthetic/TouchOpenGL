//
//  CMaterial.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/17/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CMaterial.h"

#import "COpenGLAssetLibrary.h"

@interface CMaterial ()
@property (readwrite, nonatomic, retain) NSString *name;
@property (readwrite, nonatomic, assign) Color4f ambientColor;
@property (readwrite, nonatomic, assign) Color4f diffuseColor;
@property (readwrite, nonatomic, assign) Color4f specularColor;
@property (readwrite, nonatomic, assign) GLfloat shininess;
@property (readwrite, nonatomic, assign) GLfloat alpha;

@property (readwrite, nonatomic, retain) CTexture *texture;
@end

@implementation CMaterial

@synthesize name;
@synthesize ambientColor;
@synthesize diffuseColor;
@synthesize specularColor;
@synthesize shininess;
@synthesize alpha;
@synthesize texture;

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        const GLfloat kRGB = 1.0;
        
        ambientColor = (Color4f){ kRGB, kRGB, kRGB, 1.0 };
        diffuseColor = (Color4f){ kRGB, kRGB, kRGB, 1.0 };
        specularColor = (Color4f){ kRGB, kRGB, kRGB, 1.0 };
        shininess = 1.0;
        alpha = 1.0;
		}
	return(self);
	}

- (void)dealloc
    {
    [name release];
    name = NULL;
    
    [texture release];
    texture = NULL;
    //
    [super dealloc];
    }

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (%@)", [super description], self.name]);
    }

- (id)copyWithZone:(NSZone *)zone;
    {
    #pragma unused (zone)
    
    CMaterial *theCopy = [[CMaterial alloc] init];
    theCopy.name = self.name;
    theCopy.ambientColor = self.ambientColor;
    theCopy.diffuseColor = self.diffuseColor;
    theCopy.specularColor = self.specularColor;
    theCopy.shininess = self.shininess;
    theCopy.alpha = self.alpha;
    return(theCopy);
    }

@end

#pragma mark -

@implementation CMutableMaterial

@dynamic name;
@dynamic ambientColor;
@dynamic diffuseColor;
@dynamic specularColor;
@dynamic shininess;
@dynamic alpha;
@dynamic texture;

- (id)mutableCopyWithZone:(NSZone *)zone;
    {
    #pragma unused (zone)
    
    CMutableMaterial *theCopy = [[CMutableMaterial alloc] init];
    theCopy.name = self.name;
    theCopy.ambientColor = self.ambientColor;
    theCopy.diffuseColor = self.diffuseColor;
    theCopy.specularColor = self.specularColor;
    theCopy.shininess = self.shininess;
    theCopy.alpha = self.alpha;
    return(theCopy);
    }


@end

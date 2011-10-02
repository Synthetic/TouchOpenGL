//
//  PopTipDocument.m
//  TouchOpenGL
//
//  Created by Aaron Golden on 3/21/11.
//  Copyright 2011 Aaron Golden. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY AARON GOLDEN ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL AARON GOLDEN OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Aaron Golden.

#import "CModelDocument.h"

#import "CSceneRendererView.h"
#import "CSceneRendererOpenGLLayer.h"
#import "CGeometryRenderer.h"
#import "Matrix.h"
#import "Quaternion.h"
#import "CLight.h"
#import "Color_OpenGLExtensions.h"
#import "CCamera.h"
#import "CMeshLoader.h"
#import "CArcBall.h"
#import "ArcBallView.h"
#import "COBJParser.h"
#import "CMesh.h"

@interface CModelDocument ()

@property (nonatomic, strong) ArcBallView *arcBallView;

- (void)updateMatrix;

@end

#pragma mark -

@implementation CModelDocument

@synthesize renderer;
@synthesize mainView;
@synthesize roll;
@synthesize pitch;
@synthesize yaw;
@synthesize scale;
@synthesize cameraX;
@synthesize cameraY;
@synthesize cameraZ;
@synthesize lightX;
@synthesize lightY;
@synthesize lightZ;
@synthesize arcBallView = _arcBallView;
@synthesize programs;
@synthesize defaultProgram;
@synthesize materials;

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        renderer = [[CGeometryRenderer alloc] init];

        scale = 1.0;

        CMeshLoader *theLoader = [[CMeshLoader alloc] init];
		NSURL *theURL = [[NSBundle mainBundle] URLForResource:@"teapot" withExtension:@"model.plist"];
        NSError *theError = NULL;
        if ([theLoader loadMeshWithURL:theURL error:&theError] == NO)
            {
            NSLog(@"FAILURE: %@", theError);
            }
        self.renderer.mesh = theLoader.mesh;
        self.materials = [theLoader.materials allValues];

        NSLog(@"%@", self.materials);

        self.cameraX = self.renderer.camera.position.x;
        self.cameraY = self.renderer.camera.position.y;
        self.cameraZ = self.renderer.camera.position.z;

        self.lightX = self.renderer.light.position.x;
        self.lightY = self.renderer.light.position.y;
        self.lightZ = self.renderer.camera.position.z;

        [self addObserver:self forKeyPath:@"renderer.light.ambientColor" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"renderer.light.diffuseColor" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"renderer.light.specularColor" options:0 context:NULL];

        NSMutableArray *thePrograms = [NSMutableArray array];
        for (NSString *thePath in [[NSFileManager defaultManager] subpathsAtPath:[[NSBundle mainBundle] resourcePath]])
            {
            if ([[thePath pathExtension] isEqualToString:@"fsh"])
                {
                NSString *theName = [[[NSFileManager defaultManager] displayNameAtPath:thePath] stringByDeletingPathExtension];
                [thePrograms addObject:theName];
                }
            }

        self.defaultProgram = @"Lighting_PerPixel";

        self.programs = thePrograms;
        }
    return self;
    }

- (void)dealloc
    {
    [self removeObserver:self forKeyPath:@"renderer.light.ambientColor"];
    [self removeObserver:self forKeyPath:@"renderer.light.diffuseColor"];
    [self removeObserver:self forKeyPath:@"renderer.light.specularColor"];
    }

- (NSString *)windowNibName
    {
    return @"CModelDocument";
    }

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
    {
    [super windowControllerDidLoadNib:aController];
    //
    [self.mainView setWantsLayer:YES];
    self.mainView.rendererLayer.renderer = self.renderer;

    self.arcBallView = [[ArcBallView alloc] initWithFrame:self.mainView.bounds];
    self.arcBallView.document = self;
    [self.mainView addSubview:self.arcBallView];
    }

#pragma mark -

- (void)setRoll:(GLfloat)inRoll
    {
    roll = inRoll;

    [self updateMatrix];
    }

- (void)setPitch:(GLfloat)inPitch
    {
    pitch = inPitch;

    [self updateMatrix];
    }

- (void)setYaw:(GLfloat)inYaw
    {
    yaw = inYaw;

    [self updateMatrix];
    }

- (void)setScale:(GLfloat)inScale
    {
    scale = inScale;

    [self updateMatrix];
    }

- (void)setCameraX:(GLfloat)inCameraX
    {
    cameraX = inCameraX;

    Vector4 theCameraPosition = self.renderer.camera.position;
    theCameraPosition.x = inCameraX;
    self.renderer.camera.position = theCameraPosition;
    }

- (void)setCameraY:(GLfloat)inCameraY
    {
    cameraY = inCameraY;

    Vector4 theCameraPosition = self.renderer.camera.position;
    theCameraPosition.y = inCameraY;
    self.renderer.camera.position = theCameraPosition;
    }

- (void)setCameraZ:(GLfloat)inCameraZ
    {
    cameraZ = inCameraZ;

    Vector4 theCameraPosition = self.renderer.camera.position;
    theCameraPosition.z = inCameraZ;
    self.renderer.camera.position = theCameraPosition;
    }

- (void)setLightX:(GLfloat)inLightX
    {
    lightX = inLightX;

    Vector4 theLightPosition = self.renderer.light.position;
    theLightPosition.x = inLightX;
    self.renderer.light.position = theLightPosition;
    }

- (void)setLightY:(GLfloat)inLightY
    {
    lightY = inLightY;

    Vector4 theLightPosition = self.renderer.light.position;
    theLightPosition.y = inLightY;
    self.renderer.light.position = theLightPosition;
    }

- (void)setLightZ:(GLfloat)inLightZ
    {
    lightZ = inLightZ;

    Vector4 theLightPosition = self.renderer.light.position;
    theLightPosition.z = inLightZ;
    self.renderer.light.position = theLightPosition;
    }

- (void)setDefaultProgram:(NSString *)inDefaultProgram
    {
    if (defaultProgram != inDefaultProgram)
        {
        defaultProgram = inDefaultProgram;

        self.renderer.defaultProgramName = defaultProgram;

        [self.renderer setNeedsSetup];
        }
    }

#pragma mark -

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
    {
    if (outError)
        {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
        }
    return nil;
    }

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
    {
    if ([typeName isEqualToString:@"obj"])
        {
        COBJParser *theParser = [[COBJParser alloc] initWithURL:absoluteURL];
        NSError *theError = NULL;
        [theParser parse:&theError];

        self.renderer.mesh = theParser.mesh;
        self.materials = [theParser.mesh.geometries valueForKeyPath:@"material"];

        return(YES);
        }
    else if ([typeName isEqualToString:@"obj"] && NO)
        {
    //    NSString *theInputFile = [NSString stringWithFormat:@"'%@'", absoluteURL.path];
        char thePath[] = "/tmp/XXXXXXXX";
        NSString *theOutputPath = [NSString stringWithFormat:@"%s", mkdtemp(thePath)];
        NSString *theScript = [NSString stringWithFormat:@"OBJConverter --input '%@' --output '%@'", absoluteURL.path, theOutputPath];

        NSLog(@"Running script");
        NSTask *theTask = [[NSTask alloc] init];
        [theTask setLaunchPath:@"/bin/bash"];
        [theTask setArguments:[NSArray arrayWithObjects:@"--login", @"-c", theScript, NULL]];
//        [theTask setStandardOutput:[NSFileHandle fileHandleWithNullDevice]];
//        [theTask setStandardError:[NSFileHandle fileHandleWithNullDevice]];
        [theTask launch];
        [theTask waitUntilExit];
        NSLog(@"Script Returned: %d", [theTask terminationStatus]);


        theOutputPath = [theOutputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.model.plist", [[absoluteURL.path stringByDeletingPathExtension] lastPathComponent]]];

        CMeshLoader *theLoader = [[CMeshLoader alloc] init];
        NSURL *theURL = [NSURL fileURLWithPath:theOutputPath];
        [theLoader loadMeshWithURL:theURL error:NULL];
        self.renderer.mesh = theLoader.mesh;
        self.materials = [theLoader.materials allValues];

    //    if (outError)
    //        {
    //        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    //        }
        return(YES);
        }
    else if ([typeName isEqualToString:@"plist"])
        {
        CMeshLoader *theLoader = [[CMeshLoader alloc] init];
        [theLoader loadMeshWithURL:absoluteURL error:NULL];
        self.renderer.mesh = theLoader.mesh;
        self.materials = [theLoader.materials allValues];

    //    if (outError)
    //        {
    //        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    //        }
        return(YES);
        }
    else
        {
        return(NO);
        }
    }

#pragma mark -

- (void)updateMatrix
    {
    self.renderer.modelTransform = Matrix4Concat(
        Matrix4MakeScale(self.scale, self.scale, self.scale),
        Matrix4FromQuaternion(QuaternionSetEuler(DegreesToRadians(self.yaw), DegreesToRadians(self.pitch), DegreesToRadians(self.roll)))
        );
    }

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
    {
    [self.renderer setNeedsSetup];
    }

@end

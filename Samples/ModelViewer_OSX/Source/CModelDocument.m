//
//  PopTipDocument.m
//  PopTipEditor
//
//  Created by Aaron Golden on 3/21/11.
//  Copyright 2011 Inkling. All rights reserved.
//

#import "CModelDocument.h"

#import "CRendererView.h"
#import "CRendererOpenGLLayer.h"
#import "COBJRenderer.h"
#import "Matrix.h"
#import "Quaternion.h"
#import "CLight.h"
#import "Color_OpenGLExtensions.h"
#import "CCamera.h"
#import "CMeshLoader.h"
#import "CArcBall.h"
#import "ArcBallView.h"

@interface CModelDocument ()

@property (nonatomic, retain) ArcBallView *arcBallView;

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
        renderer = [[COBJRenderer alloc] init];
        
        scale = 1.0;
        
        CMeshLoader *theLoader = [[[CMeshLoader alloc] init] autorelease];
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
    [mainView release];
    [renderer release];

    [self removeObserver:self forKeyPath:@"renderer.light.ambientColor"];
    [self removeObserver:self forKeyPath:@"renderer.light.diffuseColor"];
    [self removeObserver:self forKeyPath:@"renderer.light.specularColor"];
    //
    [super dealloc];
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

    self.arcBallView = [[[ArcBallView alloc] initWithFrame:self.mainView.bounds] autorelease];
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
        [defaultProgram release];
        defaultProgram = [inDefaultProgram retain];
        
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
        
        [theTask release];
        
        theOutputPath = [theOutputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.model.plist", [[absoluteURL.path stringByDeletingPathExtension] lastPathComponent]]];
        
        CMeshLoader *theLoader = [[[CMeshLoader alloc] init] autorelease];
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
        CMeshLoader *theLoader = [[[CMeshLoader alloc] init] autorelease];
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

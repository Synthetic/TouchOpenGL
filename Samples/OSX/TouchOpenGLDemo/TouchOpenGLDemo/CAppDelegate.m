//
//  CAppDelegate.m
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 6/23/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import "CAppDelegate.h"

#import "COpenGLRendererView.h"
#import "CSceneRendererView.h"
#import "CTextureRenderer.h"
#import "CTexture_Utilities.h"
#import "COffscreenOpenGLContext.h"
#import "COpenGLContext+Debugging.h"

@interface CAppDelegate ()
@property (readwrite, nonatomic, assign) IBOutlet COpenGLRendererView *rendererView;
@property (readwrite, nonatomic, strong) IBOutlet CTextureRenderer *renderer;
@end

#pragma mark -

@implementation CAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
    {
    self.renderer = [[CTextureRenderer alloc] init];
    self.renderer.textureBlock = ^(void) {
        CTexture *theTexture = [CTexture textureNamed:@"lena_std.tiff" error:NULL];
        return(theTexture);
        };

#if 1
    self.rendererView.renderer = self.renderer;
#else

    COffscreenOpenGLContext *theContext = [[COffscreenOpenGLContext alloc] initWithSize:(SIntSize){ 1024, 1024 }];
    [theContext dump];
    [theContext render:self.renderer];

    CTexture *theTexture = [theContext readTextureSize:theContext.size];

    [theTexture writeToFile:@"/Users/schwa/Desktop/test.png"];
    [theContext dump];

#endif
    }

@end

//
//  CAppDelegate.m
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 6/23/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import "CAppDelegate.h"

#import "COpenGLRendererView.h"
#import "CTextureRenderer.h"
#import "CTexture_Utilities.h"

@interface CAppDelegate ()
@property (readwrite, nonatomic, assign) IBOutlet COpenGLRendererView *rendererView;
@property (readwrite, nonatomic, strong) IBOutlet CTextureRenderer *renderer;
@end

@implementation CAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
    {
    self.renderer = [[CTextureRenderer alloc] init];
    self.renderer.textureBlock = ^(void) {
        CTexture *theTexture = [CTexture textureNamed:@"lena_std.tiff" error:NULL];
        return(theTexture);
        };
    self.rendererView.renderer = self.renderer;
    }

@end

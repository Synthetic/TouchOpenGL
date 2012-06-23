//
//  CAppDelegate.m
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 6/23/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import "CAppDelegate.h"

#import "COpenGLRendererView.h"
#import "CSceneRenderer.h"

@interface CAppDelegate ()
@property (readwrite, nonatomic, assign) IBOutlet COpenGLRendererView *rendererView;
@property (readwrite, nonatomic, strong) IBOutlet CSceneRenderer *renderer;
@end

@implementation CAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
    {
    self.renderer = [[CSceneRenderer alloc] init];
    self.rendererView.renderer = self.renderer;
    }

@end

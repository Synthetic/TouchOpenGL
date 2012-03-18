//
//  CViewController.m
//  OpenGLTest
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CViewController.h"

#import "CRendererView.h"
#import "CTestSceneRenderer.h"

@implementation CViewController

@synthesize rendererView;

- (void)viewDidLoad
    {
    [super viewDidLoad];
    
    self.rendererView.renderer = [[CTestSceneRenderer alloc] init];
    }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
    {
    return YES;
    }

@end

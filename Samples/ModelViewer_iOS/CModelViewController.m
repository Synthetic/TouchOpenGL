//
//  SketchTestViewController.m
//  SketchTest
//
//  Created by Jonathan Wight on 02/15/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CModelViewController.h"

#import "CInteractiveRendererView.h"
#import "CMeshLoader.h"
#import "COBJRenderer.h"

@interface CModelViewController () <UIActionSheetDelegate>

@end

@implementation CModelViewController

- (CInteractiveRendererView *)rendererView
    {
    return((CInteractiveRendererView *)self.view);
    }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
    {
    #pragma unused (interfaceOrientation)
    return(YES);
    }
    
- (void)viewDidLoad
    {
    [super viewDidLoad];

    CMeshLoader *theLoader = [[[CMeshLoader alloc] init] autorelease];
    
    NSURL *theURL = [[NSBundle mainBundle] URLForResource:@"Liberty" withExtension:@"model.plist"];
    
    CMesh *theMesh = [theLoader loadMeshWithURL:theURL error:NULL];
    
    COBJRenderer *theRenderer = [[[COBJRenderer alloc] init] autorelease];
    theRenderer.mesh = theMesh;
    
    self.rendererView.renderer = theRenderer;
    }

- (IBAction)click:(id)inSender;
    {
    UIActionSheet *theActionSheet = [[[UIActionSheet alloc] initWithTitle:NULL delegate:self cancelButtonTitle:NULL destructiveButtonTitle:NULL otherButtonTitles:NULL] autorelease];
    
    
    
    NSArray *theContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] resourcePath] error:NULL];
    for (NSString *thePath in theContents)
        {
        if ([thePath rangeOfString:@".model.plist"].location != NSNotFound)
            {
            NSLog(@"%@", thePath);
            [theActionSheet addButtonWithTitle:thePath];
            
            }
        }
    
    
    [theActionSheet showFromRect:[self.view convertRect:[inSender frame] toView:self.view] inView:self.view animated:YES];
    }

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
    {
    #pragma unused (actionSheet)

    NSString *theFilename = [actionSheet buttonTitleAtIndex:buttonIndex];

    NSURL *theURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:theFilename];
    
    CMeshLoader *theLoader = [[[CMeshLoader alloc] init] autorelease];
    CMesh *theMesh = [theLoader loadMeshWithURL:theURL error:NULL];
    
//    COBJRenderer *theRenderer = [[[COBJRenderer alloc] init] autorelease];
//    theRenderer.mesh = theMesh;
    
    ((COBJRenderer *)self.rendererView.renderer).mesh = theMesh;
    }

@end

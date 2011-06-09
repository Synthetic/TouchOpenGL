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
#import "CMesh.h"

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
    
- (void)awakeFromNib
    {
    CMeshLoader *theLoader = [[[CMeshLoader alloc] init] autorelease];
    
    NSString *theDefaultMeshFilename = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeshFilename"];
    theDefaultMeshFilename = [theDefaultMeshFilename stringByDeletingPathExtension];
    if (theDefaultMeshFilename.length == 0)
        {
        theDefaultMeshFilename = @"teapot";
        }
    
    NSURL *theURL = [[NSBundle mainBundle] URLForResource:theDefaultMeshFilename withExtension:@"model.plist"];
    
    NSError *theError = NULL;
    [theLoader loadMeshWithURL:theURL error:&theError];
    CMesh *theMesh = theLoader.mesh;
    if (theMesh == NULL)
        {
        NSLog(@"%@", theError);
        }
    
    COBJRenderer *theRenderer = [[[COBJRenderer alloc] init] autorelease];
    theRenderer.mesh = theMesh;
    
    self.rendererView.renderer = theRenderer;
    }

- (IBAction)click:(id)inSender;
    {
    UIActionSheet *theActionSheet = [[[UIActionSheet alloc] initWithTitle:NULL delegate:self cancelButtonTitle:NULL destructiveButtonTitle:NULL otherButtonTitles:NULL] autorelease];
    
    NSArray *theContents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[[NSBundle mainBundle] resourcePath] error:NULL];
    for (NSString *thePath in theContents)
        {
        if ([thePath rangeOfString:@".model.plist"].location != NSNotFound)
            {
            [theActionSheet addButtonWithTitle:thePath];
            }
        }
    
    [theActionSheet showFromRect:[self.view convertRect:[inSender frame] toView:self.view] inView:self.view animated:YES];
    }

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
    {
    #pragma unused (actionSheet)

    if (buttonIndex >= 0)
        {
        NSString *theFilename = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        [[NSUserDefaults standardUserDefaults] setObject:[theFilename stringByDeletingPathExtension] forKey:@"MeshFilename"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        NSURL *theURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:theFilename];
        
        CMeshLoader *theLoader = [[[CMeshLoader alloc] init] autorelease];
        [theLoader loadMeshWithURL:theURL error:NULL];
        CMesh *theMesh = theLoader.mesh;
        
    //    COBJRenderer *theRenderer = [[[COBJRenderer alloc] init] autorelease];
    //    theRenderer.mesh = theMesh;
        
        ((COBJRenderer *)self.rendererView.renderer).mesh = theMesh;
        [self.rendererView.renderer setup];
        }
    }

@end

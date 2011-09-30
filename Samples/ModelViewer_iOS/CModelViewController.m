//
//  SketchTestViewController.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 02/15/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
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
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

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

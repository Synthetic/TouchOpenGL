//
//  CDetailViewController.m
//  SimpleTextureTest
//
//  Created by Jonathan Wight on 3/18/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CDetailViewController.h"
#import "CRendererView.h"
#import "CTestRenderer.h"
#import "COpenGLContext.h"
#import "CAssetLibrary.h"
#import "CAutomagicBlitProgram.h"
#import "CVertexBufferReference_FactoryExtensions.h"

@interface CDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (readwrite, nonatomic, strong) IBOutlet CRendererView *rendererView;
@property (readwrite, nonatomic, strong) CTestRenderer *renderer;

- (void)configureView;
@end

@implementation CDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
	

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
	{
	if (self.detailItem) {
	    self.detailDescriptionLabel.text = [self.detailItem description];
	}
	
	self.renderer = [[CTestRenderer alloc] init];
	self.renderer.setupBlock = ^(void) {
		self.renderer.texture = [self.renderer.context.assetLibrary textureNamed:@"lena_std.tiff" error:NULL];
		self.renderer.program = [[CAutomagicBlitProgram alloc] init];
		[self.renderer.program use];
		self.renderer.program.texCoords = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ .size = { 1.0, 1.0 } }];
		self.renderer.program.positions = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ -1, -1, 2, 2 }];
		self.renderer.program.projectionMatrix = Matrix4MakeScale(-1.0, -1.0, 1.0);


		};
	self.rendererView.renderer = self.renderer;
	}

							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end

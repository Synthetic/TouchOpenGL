//
//  CViewController.h
//  OpenGLTest
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRendererView;

@interface CViewController : UIViewController

@property (readwrite, nonatomic, retain) IBOutlet CRendererView *rendererView;


@end

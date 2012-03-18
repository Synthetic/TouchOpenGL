//
//  CMasterViewController.h
//  SimpleTextureTest
//
//  Created by Jonathan Wight on 3/18/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDetailViewController;

@interface CMasterViewController : UITableViewController

@property (strong, nonatomic) CDetailViewController *detailViewController;

@end

//
//  LEDModuleTableViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/12/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirmataService.h"

@class LEDModuleTableViewController;
@protocol LEDModuleTableViewControllerDelegate <NSObject>
- (void)ledModuleTableViewControllerDismissed:(LEDModuleTableViewController *)controller;
@end

@interface LEDModuleTableViewController : UITableViewController <FirmataServiceDelegate>
@property (weak, nonatomic) id <LEDModuleTableViewControllerDelegate> delegate;
- (IBAction)dismissModule;
@end

//
//  LeDiscoveryTableViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LeDiscoveryManager.h"


@class LeDiscoveryTableViewController;
@protocol LeDiscoveryTableViewControllerDelegate <NSObject>
- (void)leDiscoveryTableViewControllerDismissed:(LeDiscoveryTableViewController *)controller;
@end

@interface LeDiscoveryTableViewController : UITableViewController <LeDiscoveryManagerDelegate>
@property (weak, nonatomic) id <LeDiscoveryTableViewControllerDelegate> delegate;
@end

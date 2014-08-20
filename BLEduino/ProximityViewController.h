//
//  ProximityViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/18/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DistanceAlertController.h"
#import "RSSIAlertController.h"
#import "BDLeDiscoveryManager.h"

@class ProximityViewController;
@protocol ProximityViewControllerDelegate <NSObject>
- (void) proximityControllerDismissed:(ProximityViewController *)controller;
@end

@interface ProximityViewController : UIViewController
<
UITableViewDelegate,
UITableViewDataSource,
UIAlertViewDelegate,
UIActionSheetDelegate,
DistanceAlertControllerDelegate,
RSSIAlertControllerDelegate,
LeDiscoveryManagerDelegate
>
@property (weak) id <ProximityViewControllerDelegate> delegate;
@property IBOutlet UITableView *tableView;

//Distance
@property IBOutlet UIImageView *distanceIndicator;
@property NSString *distanceFormat;

//Alerts
@property NSInteger indexOfLastAlertUpdated;
@property NSMutableArray *alerts;

//Calibration
@property IBOutlet UIActivityIndicatorView *calibrationIndicator;
@property IBOutlet UILabel *calibrationLabel;
@property IBOutlet UILabel *rangeLabel;
@property IBOutlet UILabel *rssiLabel;
@property IBOutlet UILabel *distanceLabel;

- (IBAction)addAlert:(id)sender;
- (IBAction)calibrate:(id)sender;
- (IBAction)dismissModule:(id)sender;
@end

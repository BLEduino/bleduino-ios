//
//  ProximityViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/18/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DistanceAlertController.h"
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
DistanceAlertControllerDelegate,
LeDiscoveryManagerDelegate
>
@property (weak) id <ProximityViewControllerDelegate> delegate;
@property IBOutlet UITableView *tableView;

//Distance
@property IBOutlet UILabel *distanceIndicator;
@property NSString *distanceFormat;
@property BOOL distanceFormatIsFeet;

//Alerts
@property NSInteger indexOfLastAlertUpdated;
@property NSMutableArray *alerts;

//Calibration
@property IBOutlet UIActivityIndicatorView *calibrationIndicator;
@property IBOutlet UILabel *calibrationLabel;

- (IBAction)calibrate:(id)sender;
- (IBAction)dismissModule:(id)sender;
@end

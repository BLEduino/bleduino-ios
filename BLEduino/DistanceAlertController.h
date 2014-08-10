//
//  EditDistanceAlertController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/18/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProximityAlert.h"

@class DistanceAlertController;
@protocol DistanceAlertControllerDelegate <NSObject>
- (void) distanceAlertControllerDismissed:(DistanceAlertController *)controller;
- (void) didCreateDistanceAlert:(ProximityAlert *)alert fromController:(DistanceAlertController *)controller;
- (void) didUpdateDistanceAlert:(ProximityAlert *)alert fromController:(DistanceAlertController *)controller;
@end

@interface DistanceAlertController : UITableViewController <UITextFieldDelegate>
@property (weak) id <DistanceAlertControllerDelegate> delegate;
@property ProximityAlert *alert;
@property BOOL isNewAlert;
@property IBOutlet UITextField *message;
@property IBOutlet UISegmentedControl *distanceControl;
@property IBOutlet UISwitch *alertWhenCloser;
@property IBOutlet UISwitch *alertWhenFarther;

- (IBAction)dismissModule:(id)sender;
- (IBAction)updateDistanceAlert:(id)sender;
@end

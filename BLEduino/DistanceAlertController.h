//
//  EditDistanceAlertController.h
//  BLEduino
//
//  Created by Valerie Ann Rodriguez on 7/18/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DistanceAlert.h"

@class DistanceAlertController;
@protocol DistanceAlertControllerDelegate <NSObject>
- (void) distanceAlertControllerDismissed:(DistanceAlertController *)controller;
- (void) didCreateDistanceAlert:(DistanceAlert *)alert fromController:(DistanceAlertController *)controller;
- (void) didUpdateDistanceAlert:(DistanceAlert *)alert fromController:(DistanceAlertController *)controller;
@end

@interface DistanceAlertController : UITableViewController <UITextFieldDelegate>
@property (weak) id <DistanceAlertControllerDelegate> delegate;
@property DistanceAlert *alert;
@property BOOL isNewAlert;
@property IBOutlet UITextField *messageLabel;
@property IBOutlet UISlider *distanceSlider;
@property IBOutlet UILabel *distanceIndicator;
@property IBOutlet UISwitch *alertWhenCloser;
@property IBOutlet UISwitch *alertWhenFarther;
@property NSString *distanceFormat;

- (IBAction)dismissModule:(id)sender;
- (IBAction)updateDistanceAlert:(id)sender;
@end

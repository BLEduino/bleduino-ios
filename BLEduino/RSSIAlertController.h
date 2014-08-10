//
//  RSSIDistanceAlertController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/9/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProximityAlert.h"

@class RSSIAlertController;
@protocol RSSIAlertControllerDelegate <NSObject>
- (void) rssiAlertControllerDismissed:(RSSIAlertController *)controller;
- (void) didCreateRSSIAlert:(ProximityAlert *)alert
             fromController:(RSSIAlertController *)controller;
- (void) didUpdateRSSIAlert:(ProximityAlert *)alert
             fromController:(RSSIAlertController *)controller;
@end

@interface RSSIAlertController : UITableViewController <UITextFieldDelegate>
@property (weak) id <RSSIAlertControllerDelegate> delegate;
@property ProximityAlert *alert;
@property BOOL isNewAlert;
@property IBOutlet UITextField *message;
@property IBOutlet UISlider *rssiSlider;
@property IBOutlet UILabel *rssiIndicator;
@property IBOutlet UISwitch *alertWhenCloser;
@property IBOutlet UISwitch *alertWhenFarther;

- (IBAction)dismissModule:(id)sender;
- (IBAction)updateRSSIAlert:(id)sender;
@end
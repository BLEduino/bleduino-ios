//
//  BLEduinoTableViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/15/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#pragma mark -
#pragma mark Bleduino Controller Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BleduinoController;
@protocol BleduinoControllerDelegate <NSObject>
- (void)didUpateBleduino:(CBPeripheral *)bleduino controller:(BleduinoController *)controller;
- (void)didDismissBleduinoController:(BleduinoController *)controller;
@end

@interface BleduinoController : UITableViewController <UITextFieldDelegate>
@property (weak) id <BleduinoControllerDelegate> delegate;
@property IBOutlet UITextField *bleduinoName;
@property CBPeripheral *bleduino;
- (IBAction) dismissModule:(id)sender;
- (IBAction) updateBleduinoName:(id)sender;
@end

//
//  SequencerTableViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 6/13/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BDLeManager.h"
#import "BDFirmata.h"
#import "BDFirmataCommand.h"
#import "BDBleduino.h"

#import "FirmataAnalogCell.h"
#import "FirmataDigitalCell.h"
#import "FirmataPWMCell.h"
#import "TimeDelayTableViewCell.h"

@class SequencerTableViewController;
@protocol SequencerTableViewControllerDelegate <NSObject>
- (void) sequencerTableViewControllerDismissed:(SequencerTableViewController *)controller;
@end

@interface SequencerTableViewController : UITableViewController
<
FirmataServiceDelegate,
BleduinoDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate,
UITextFieldDelegate
>
@property (weak) id <SequencerTableViewControllerDelegate> delegate;
@property (strong) NSMutableArray *sequence;
@property (strong) BDBleduino *firmata;
@property (strong) BDFirmataCommand *start;
@property (strong) BDFirmataCommand *end;
@property IBOutlet UIBarButtonItem *edit;
@property IBOutlet UIBarButtonItem *addCommand;
@property IBOutlet UIBarButtonItem *addDelay;

- (IBAction)addCommand:(id)sender;
- (IBAction)addDelay:(id)sender;
- (IBAction)sendSequence:(id)sender;
- (IBAction)editSequence:(id)sender;
- (IBAction)dismissModule;
@end

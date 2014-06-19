//
//  SequencerTableViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 6/13/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BDLeDiscoveryManager.h"
#import "BDFirmataService.h"
#import "BDFirmataCommandCharacteristic.h"

#import "FirmataAnalogCell.h"
#import "FirmataDigitalCell.h"
#import "FirmataPWMCell.h"

@class SequencerTableViewController;
@protocol SequencerTableViewControllerDelegate <NSObject>
- (void) sequencerTableViewControllerDismissed:(SequencerTableViewController *)controller;
@end

@interface SequencerTableViewController : UITableViewController
<
FirmataServiceDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate,
UITextFieldDelegate
>
@property (weak) id <SequencerTableViewControllerDelegate> delegate;
@property (strong) NSMutableArray *sequence;
@property (strong) BDFirmataService *firmata;
@property (strong) BDFirmataCommandCharacteristic *start;
@property (strong) BDFirmataCommandCharacteristic *end;
@property IBOutlet UIBarButtonItem *edit;
@property IBOutlet UIBarButtonItem *addCommand;

- (IBAction)addCommand:(id)sender;
- (IBAction)addDelay:(id)sender;
- (IBAction)sendSequence:(id)sender;
- (IBAction)editSequence:(id)sender;
- (IBAction)dismissModule;
@end

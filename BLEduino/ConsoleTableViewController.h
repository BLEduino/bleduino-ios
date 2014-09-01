//
//  ConsoleTableViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/16/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDLeManager.h"
#import "BDUart.h"
#import "BDBleduino.h"
#import "PSPDFTextView.h"

@class ConsoleTableViewController;
@protocol ConsoleTableViewControllerDelegate <NSObject>
- (void) consoleControllerDismissed:(ConsoleTableViewController *)controller;
@end

@interface ConsoleTableViewController : UITableViewController
<
UITextFieldDelegate,
UITextViewDelegate,
UARTServiceDelegate,
BleduinoDelegate
>
@property (weak) id <ConsoleTableViewControllerDelegate> delegate;
@property CGFloat keyboardHeight;
@property CGFloat keyboardWidth;
@property UITextField *consoleTextField;
@property PSPDFTextView *consoleText;
@property NSMutableArray *entries;
@property UIColor *bleduinoTextColor;
@property UIColor *iOSTextColor;
@property NSMutableArray *consoleHub;
- (IBAction)clear:(id)sender;
- (IBAction)dismissModule:(id)sender;
@end

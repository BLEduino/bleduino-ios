//
//  LCDTableViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/22/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "UARTService.h"

@class LCDTableViewController;
@protocol LCDTableViewControllerDelegate <NSObject>
- (void)lcdModuleTableViewControllerDismissed:(LCDTableViewController *)controller;
@end

@interface LCDTableViewController : UITableViewController
<
UITextViewDelegate,
UARTServiceDelegate
>
@property (strong, nonatomic) IBOutlet UITextView *messageView;
@property (strong, nonatomic) IBOutlet UILabel *charCountView;
@property (weak, nonatomic) id <LCDTableViewControllerDelegate> delegate;
- (IBAction)dismissModule;

@end

//
//  KeyboardModuleTableViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UARTService.h"

@class KeyboardModuleTableViewController;
@protocol KeyboardModuleTableViewControllerDelegate <NSObject>
- (void)keyboardModuleTableViewControllerDismissed:(KeyboardModuleTableViewController *)controller;
@end

@interface KeyboardModuleTableViewController : UITableViewController
<
UITextViewDelegate,
UARTServiceDelegate
>

@property (strong, nonatomic) IBOutlet UITextView *messageView;
@property (weak, nonatomic) id <KeyboardModuleTableViewControllerDelegate> delegate;
@end

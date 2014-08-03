//
//  SettingsTableViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/24/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDLeDiscoveryManager.h"

@interface SettingsTableViewController : UITableViewController
<
UIAlertViewDelegate,
UITextFieldDelegate,
UIActionSheetDelegate,
LeDiscoveryManagerDelegate
>
- (IBAction)showMenu;
- (void)showStatusBar;
@end

//
//  SideMenuTableViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/12/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface SideMenuTableViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
RESideMenuDelegate,
MFMailComposeViewControllerDelegate,
UIAlertViewDelegate
>

@property (strong, readwrite, nonatomic) UITableView *tableView;


@end

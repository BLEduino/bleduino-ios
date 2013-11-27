//
//  LeDiscoveryTableViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BDLeDiscoveryManager.h"

@interface LeDiscoveryTableViewController : UITableViewController <LeDiscoveryManagerDelegate>
@property (strong, nonatomic) NSArray *connectedBleduinos;
@property (strong, nonatomic) NSArray *foundBleduinos;
- (IBAction)showMenu;
- (void)showStatusBar;
@end

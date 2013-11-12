//
//  ModulesCollectionViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardModuleTableViewController.h"
#import "LeDiscoveryTableViewController.h"
#import "NotificationService.h"
#import "BleBridgeService.h"

@interface ModulesCollectionViewController : UICollectionViewController
<
UICollectionViewDelegateFlowLayout,
KeyboardModuleTableViewControllerDelegate,
LeDiscoveryTableViewControllerDelegate
>
@property (nonatomic, strong) NSArray *modules;
@property (nonatomic, strong) NSArray *modulesImages;

//Services that run in the background.
@property (strong, nonatomic) NotificationService *notifications;
@property (strong, nonatomic) BleBridgeService *bleBridge;

- (IBAction)showMenu;
@end

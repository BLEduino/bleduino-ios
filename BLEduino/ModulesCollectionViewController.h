//
//  ModulesCollectionViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

//Modules
#import "BDLeDiscoveryManager.h"
#import "LCDTableViewController.h"
#import "KeyboardModuleTableViewController.h"
#import "GameControllerViewController.h"
#import "RadioControlledViewController.h"
#import "PowerRelayViewController.h"
#import "LEDModuleTableViewController.h"
#import "BDNotificationService.h"
#import "BDBleBridgeService.h"
#import "FirmataTableViewController.h"
#import "SequencerTableViewController.h"
#import "ProximityViewController.h"
#import "ConsoleTableViewController.h"
#import "BDNotificationService.h"
#import "BDProximity.h"

@interface ModulesCollectionViewController : UICollectionViewController
<
UICollectionViewDelegateFlowLayout,
CBPeripheralDelegate,
LCDTableViewControllerDelegate,
KeyboardModuleTableViewControllerDelegate,
GameControllerViewControllerDelegate,
RadioControlledViewControllerDelegate,
PowerRelayViewControllerDelegate,
LEDModuleTableViewControllerDelegate,
FirmataTableViewControllerDelegate,
SequencerTableViewControllerDelegate,
ProximityViewControllerDelegate,
ConsoleTableViewControllerDelegate,
NotificationServiceDelegate,
LeDiscoveryManagerDelegate,
BleBridgeServiceDelegate
>
@property (nonatomic, strong) NSArray *modules;
@property (nonatomic, strong) NSArray *modulesImages;

//Services that run in the background.
@property (strong) BDBleBridgeService *bleBridge;
@property (strong) BDNotificationService *notificationService;
@property (strong) BDProximity *proximityMonitor;

//Proximity
@property (strong) NSMutableArray *distanceAlerts;
@property BOOL distanceAlertsEnabled;

- (IBAction)showMenu;
- (void)showStatusBar;

@end

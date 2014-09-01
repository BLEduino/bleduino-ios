//
//  PowerRelayViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDLeManager.h"
#import "BDFirmata.h"
#import "PowerSwitchButtonView.h"
#import "PowerNextStateView.h"
#import "BDBleduino.h"

@class PowerRelayViewController;
@protocol PowerRelayViewControllerDelegate <NSObject>
- (void)powerRelayModulViewControllerDismissed:(PowerRelayViewController *)controller;
@end

@interface PowerRelayViewController : UIViewController
<
CBPeripheralDelegate,
FirmataServiceDelegate,
PowerSwitchButtonViewDelegate,
PowerNextStateViewDelegate,
BleduinoDelegate
>
@property (weak) id <PowerRelayViewControllerDelegate> delegate;
@property BOOL isLastPowerRelayStateON;
- (IBAction)dismissModule;
@end

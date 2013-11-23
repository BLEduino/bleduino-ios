//
//  PowerRelayViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirmataService.h"
#import "PowerSwitchButtonView.h"

@class PowerRelayViewController;
@protocol PowerRelayViewControllerDelegate <NSObject>
- (void)powerRelayModulViewControllerDismissed:(PowerRelayViewController *)controller;
@end

@interface PowerRelayViewController : UIViewController
<
CBPeripheralDelegate,
FirmataServiceDelegate,
PowerSwitchButtonViewDelegate
>
@property (weak, nonatomic) id <PowerRelayViewControllerDelegate> delegate;
- (IBAction)dismissModule;
@end

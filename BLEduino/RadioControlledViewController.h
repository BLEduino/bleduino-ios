//
//  RadioControlledViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDLeManager.h"
#import "BDVehicleMotion.h"
#import "BDBleduino.h"
#import "VerticalJoystickControlView.h"
#import "HorizontalJoystickControlView.h"

@class RadioControlledViewController;
@protocol RadioControlledViewControllerDelegate <NSObject>
- (void)radioControlledModuleViewControllerDismissed:(RadioControlledViewController *)controller;
@end

@interface RadioControlledViewController : UIViewController
<
VehicleMotionServiceDelegate,
VerticalJoystickControlViewDelegate,
HorizontalJoystickControlViewDelegate
>
@property (weak) id <RadioControlledViewControllerDelegate> delegate;

- (IBAction)dismissModule;
@end



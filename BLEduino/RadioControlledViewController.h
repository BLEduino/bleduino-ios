//
//  RadioControlledViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleMotionService.h"
#import "VerticalJoystickControlView.h"
#import "HorizontalJoystickControlView.h"

@interface RadioControlledViewController : UIViewController
<
VehicleMotionServiceDelegate,
VerticalJoystickControlViewDelegate,
HorizontalJoystickControlViewDelegate
>
@end



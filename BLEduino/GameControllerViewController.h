//
//  GameControllerViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControllerService.h"
#import "MFLJoystick.h"

@interface GameControllerViewController : UIViewController
<
ControllerServiceDelegate,
JoystickDelegate
>
@end

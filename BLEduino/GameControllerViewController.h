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

- (IBAction)upButton:(id)sender;
- (IBAction)leftButton:(id)sender;

- (IBAction)aButton:(id)sender;
- (IBAction)bButton:(id)sender;
- (IBAction)xButton:(id)sender;
- (IBAction)yButton:(id)sender;
@end

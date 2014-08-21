//
//  GameControllerViewController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDLeDiscoveryManager.h"
#import "BDController.h"
#import "MFLJoystick.h"

@class GameControllerViewController;
@protocol GameControllerViewControllerDelegate <NSObject>
- (void)gameControllerModuleViewControllerDismissed:(GameControllerViewController *)controller;
@end

@interface GameControllerViewController : UIViewController
<
ControllerServiceDelegate,
JoystickDelegate,
LeDiscoveryManagerDelegate
>
@property (weak) id <GameControllerViewControllerDelegate> delegate;
@property CGPoint lastPosition;
- (void)dismissModule;
@end

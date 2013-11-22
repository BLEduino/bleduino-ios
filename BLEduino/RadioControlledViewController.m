//
//  RadioControlledViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "RadioControlledViewController.h"
#import "LeDiscoveryManager.h"
#import "VehicleMotionService.h"
#import "ThrottleYawRollPitchCharacteristic.h"
#import "VerticalJoystickControlView.h"
#import "HorizontalJoystickControlView.h"

@implementation RadioControlledViewController
{
    ThrottleYawRollPitchCharacteristic *_lastThrottleYawUpdate;
    IBOutlet VerticalJoystickControlView *vJoystick;
    IBOutlet HorizontalJoystickControlView *hJoystick;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _lastThrottleYawUpdate = [[ThrottleYawRollPitchCharacteristic alloc] init];
        _lastThrottleYawUpdate.throttle = 135; //0 speed.
        _lastThrottleYawUpdate.yaw = 135; //0 turn.
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    vJoystick.delegate = self;
    hJoystick.delegate = self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//Joystick Delegates
#pragma mark -
#pragma mark - Joystick Delegates
/****************************************************************************/
/*				         Joystick Delegates                                 */
/****************************************************************************/


//Yaw Joystick.
//Resolution: 180, 135 > neutral, 45 > -90 (Max left), 225 > 90 (Max right)
- (void)horizontalJoystickDidUpdate:(CGPoint)position
{
    //Create ThrottleYawRollPitchCharacteristic update.
    ThrottleYawRollPitchCharacteristic *newThrottleYawUpdate = [[ThrottleYawRollPitchCharacteristic alloc] init];
    newThrottleYawUpdate.throttle = _lastThrottleYawUpdate.throttle;
    newThrottleYawUpdate.yaw = position.x;
    _lastThrottleYawUpdate = newThrottleYawUpdate; //Update last instance.
    
    //Send ThrottleYaw update.
    VehicleMotionService *motionService = [[VehicleMotionService alloc] initWithPeripheral:nil
                                                                                controller:self];
    [motionService writeMotionUpdate:newThrottleYawUpdate];
    NSLog(@"Sent ThrottleYaw update, yaw: %i, throttle: %i", _lastThrottleYawUpdate.yaw, _lastThrottleYawUpdate.throttle);
}

//Throttle Joystick.
//Resolution: 180, 135 > neutral, 45 > 90 (Max up), 225 > -90 (Max down)
- (void)verticalJoystickDidUpdate:(CGPoint)position
{
    //Create ThrottleYawRollPitchCharacteristic update.
    ThrottleYawRollPitchCharacteristic *newThrottleYawUpdate = [[ThrottleYawRollPitchCharacteristic alloc] init];
    newThrottleYawUpdate.throttle = position.y;
    newThrottleYawUpdate.yaw = _lastThrottleYawUpdate.yaw;
    _lastThrottleYawUpdate = newThrottleYawUpdate; //Update last instance.
    
    //Send ThrottleYaw update.
    VehicleMotionService *motionService = [[VehicleMotionService alloc] initWithPeripheral:nil
                                                                                controller:self];
    [motionService writeMotionUpdate:newThrottleYawUpdate];
    NSLog(@"Sent ThrottleYaw update, throttle: %i, yaw: %i,", _lastThrottleYawUpdate.throttle, _lastThrottleYawUpdate.yaw);
}

@end

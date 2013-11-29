//
//  RadioControlledViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "RadioControlledViewController.h"
#import "BDLeDiscoveryManager.h"
#import "BDVehicleMotionService.h"
#import "BDThrottleYawRollPitchCharacteristic.h"
#import "VerticalJoystickControlView.h"
#import "HorizontalJoystickControlView.h"

@interface RadioControlledViewController ()
@property (strong) BDThrottleYawRollPitchCharacteristic *lastThrottleYawUpdate;
@property (weak) IBOutlet VerticalJoystickControlView *vJoystick;
@property (weak) IBOutlet HorizontalJoystickControlView *hJoystick;

@property (strong) UIImageView *orientationIndicator;
@property (strong) UIView *orientationIndicatorMask;
@end

@implementation RadioControlledViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.lastThrottleYawUpdate = [[BDThrottleYawRollPitchCharacteristic alloc] init];
        self.lastThrottleYawUpdate.throttle = 135; //0 speed.
        self.lastThrottleYawUpdate.yaw = 135; //0 turn.
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.vJoystick.delegate = self;
    self.hJoystick.delegate = self;
    
    //Setup orientation tracking and alert.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    self.orientationIndicatorMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 568, 320)];
    self.orientationIndicatorMask.backgroundColor = [UIColor lightTextColor];
    self.orientationIndicatorMask.alpha = 1.0;
    
    self.orientationIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(259, 80, 50, 160)];
    self.orientationIndicator.image = [UIImage imageNamed:@"rotate-left.png"];
    
    [self.view addSubview:self.orientationIndicatorMask];
    [self.view addSubview:self.orientationIndicator];
    
    //Setup dismiss button.
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.frame = CGRectMake(0, 0, 60, 50);
    [dismissButton setImage:[UIImage imageNamed:@"arrow-left.png"] forState:UIControlStateNormal];
    [dismissButton addTarget:self
                      action:@selector(dismissModule)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:dismissButton];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dismissModule
{
    [self.delegate radioControlledModuleViewControllerDismissed:self];
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start rotate left animation */
            
            [UIView beginAnimations:@"Orientation Indicator" context:nil];
            self.orientationIndicator.alpha = 1.0;
            self.orientationIndicatorMask.alpha = 1.0;
            [UIView commitAnimations];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start rotate left animation */
            
            [UIView beginAnimations:@"Orientation Indicator" context:nil];
            self.orientationIndicator.alpha = 1.0;
            self.orientationIndicatorMask.alpha = 1.0;
            [UIView commitAnimations];
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            //This is the orientation we want.
            
            [UIView beginAnimations:@"Orientation Indicator" context:nil];
            self.orientationIndicator.alpha = 0;
            self.orientationIndicatorMask.alpha = 0;
            [UIView setAnimationDuration:0.3];
            [UIView commitAnimations];
            break;
    };
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
    BDThrottleYawRollPitchCharacteristic *newThrottleYawUpdate = [[BDThrottleYawRollPitchCharacteristic alloc] init];
    newThrottleYawUpdate.throttle = self.lastThrottleYawUpdate.throttle;
    newThrottleYawUpdate.yaw = position.x;
    self.lastThrottleYawUpdate = newThrottleYawUpdate; //Update last instance.
    
    //Send ThrottleYaw update.
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        BDVehicleMotionService *motionService = [[BDVehicleMotionService alloc] initWithPeripheral:bleduino
                                                                                      delegate:self];
        [motionService writeMotionUpdate:newThrottleYawUpdate];
    }
    
    NSLog(@"Sent ThrottleYaw update, yaw: %ld, throttle: %ld",
          (long)_lastThrottleYawUpdate.yaw, (long)_lastThrottleYawUpdate.throttle);
}

//Throttle Joystick.
//Resolution: 180, 135 > neutral, 45 > 90 (Max up), 225 > -90 (Max down)
- (void)verticalJoystickDidUpdate:(CGPoint)position
{
    //Create ThrottleYawRollPitchCharacteristic update.
    BDThrottleYawRollPitchCharacteristic *newThrottleYawUpdate = [[BDThrottleYawRollPitchCharacteristic alloc] init];
    newThrottleYawUpdate.throttle = position.y;
    newThrottleYawUpdate.yaw = self.lastThrottleYawUpdate.yaw;
    self.lastThrottleYawUpdate = newThrottleYawUpdate; //Update last instance.
    
    //Send ThrottleYaw update.
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        BDVehicleMotionService *motionService = [[BDVehicleMotionService alloc] initWithPeripheral:bleduino
                                                                                      delegate:self];
        [motionService writeMotionUpdate:newThrottleYawUpdate];
    }
    
    NSLog(@"Sent ThrottleYaw update, throttle: %ld, yaw: %ld,",
          (long)_lastThrottleYawUpdate.throttle, (long)_lastThrottleYawUpdate.yaw);
}

@end

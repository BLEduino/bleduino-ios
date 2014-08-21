//
//  RadioControlledViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "RadioControlledViewController.h"
#import "BDLeDiscoveryManager.h"
#import "BDVehicleMotion.h"
#import "BDThrottleYawRollPitch.h"
#import "VerticalJoystickControlView.h"
#import "HorizontalJoystickControlView.h"

@interface RadioControlledViewController ()
@property (strong) BDThrottleYawRollPitch *lastThrottleYawUpdate;
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
    
    //Manager Delegate
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    leManager.delegate = self;
    
    //What's initial orientation?
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    BOOL isLandscape = (currentOrientation == UIDeviceOrientationLandscapeLeft);
    
    self.orientationIndicatorMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 568, 320)];
    self.orientationIndicatorMask.backgroundColor = [UIColor lightTextColor];
    self.orientationIndicatorMask.alpha = (isLandscape)?0:1.0;
    
    self.orientationIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(259, 80, 50, 160)];
    self.orientationIndicator.image = [UIImage imageNamed:@"rotate-left.png"];
    self.orientationIndicator.alpha = (isLandscape)?0:1.0;

    [self.view addSubview:self.orientationIndicatorMask];
    [self.view addSubview:self.orientationIndicator];
    
    UIColor *lightBlue = [UIColor colorWithRed:THEME_COLOR_RED/255.0
                                         green:THEME_COLOR_GREEN/255.0
                                          blue:THEME_COLOR_BLUE/255.0
                                         alpha:1.0];
    
    //Setup dismiss button.
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.frame = CGRectMake(0, 0, 60, 50);
    dismissButton.tintColor = lightBlue;
    [dismissButton setImage:[UIImage imageNamed:@"arrow-left.png"] forState:UIControlStateNormal];
    [dismissButton addTarget:self
                      action:@selector(dismissModule)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:dismissButton];
    
    self.lastThrottleYawUpdate = [[BDThrottleYawRollPitch alloc] init];
    self.lastThrottleYawUpdate.throttle = 15; //0 speed.
    self.lastThrottleYawUpdate.yaw = 15; //0 turn.
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
            
        case UIDeviceOrientationLandscapeRight:
            /* start rotate left animation */
            
            [UIView beginAnimations:@"Orientation Indicator" context:nil];
            self.orientationIndicator.alpha = 1.0;
            self.orientationIndicatorMask.alpha = 1.0;
            [UIView setAnimationDuration:0.3];
            [UIView commitAnimations];
            break;
            
        default:
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
//Resolution:  30, 0 > 90 (Max up), 30 > -90 (Max down), 15 > neutral <- Adapted to this resolution.
- (void)horizontalJoystickDidUpdate:(CGPoint)position
{
    //Create ThrottleYawRollPitchCharacteristic update.
    BDThrottleYawRollPitch *newThrottleYawUpdate = [[BDThrottleYawRollPitch alloc] init];
    newThrottleYawUpdate.throttle = self.lastThrottleYawUpdate.throttle;
    newThrottleYawUpdate.yaw = position.x;
    self.lastThrottleYawUpdate = newThrottleYawUpdate; //Update last instance.
    
    //Send ThrottleYaw update.
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        BDVehicleMotion *motionService = [[BDVehicleMotion alloc] initWithPeripheral:bleduino
                                                                                      delegate:self];
        [motionService writeMotionUpdate:newThrottleYawUpdate];
    }
    
    NSLog(@"Sent ThrottleYaw update, yaw: %ld, throttle: %ld",
          (long)_lastThrottleYawUpdate.yaw, (long)_lastThrottleYawUpdate.throttle);
}

//Throttle Joystick.
//Resolution: 180, 135 > neutral, 45 > 90 (Max up), 225 > -90 (Max down)
//Resolution:  30, 0 > 90 (Max up), 30 > -90 (Max down), 15 > neutral <- Adapted to this resolution.
- (void)verticalJoystickDidUpdate:(CGPoint)position
{
    //Create ThrottleYawRollPitchCharacteristic update.
    BDThrottleYawRollPitch *newThrottleYawUpdate = [[BDThrottleYawRollPitch alloc] init];
    newThrottleYawUpdate.throttle = position.y;
    newThrottleYawUpdate.yaw = self.lastThrottleYawUpdate.yaw;
    self.lastThrottleYawUpdate = newThrottleYawUpdate; //Update last instance.
    
    //Send ThrottleYaw update.
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        BDVehicleMotion *motionService = [[BDVehicleMotion alloc] initWithPeripheral:bleduino
                                                                                      delegate:self];
        [motionService writeMotionUpdate:newThrottleYawUpdate];
    }
    
    NSLog(@"Sent ThrottleYaw update, throttle: %ld, yaw: %ld,",
          (long)_lastThrottleYawUpdate.throttle, (long)_lastThrottleYawUpdate.yaw);
}

#pragma mark -
#pragma mark - LeManager Delegate
/****************************************************************************/
/*                            LeManager Delegate                            */
/****************************************************************************/
//Disconnected from BLEduino and BLE devices.
- (void) didDisconnectFromBleduino:(CBPeripheral *)bleduino error:(NSError *)error
{
    NSString *name = ([bleduino.name isEqualToString:@""])?@"BLE Peripheral":bleduino.name;
    NSLog(@"Disconnected from peripheral: %@", name);
    
    //Verify if notify setting is enabled.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL notifyDisconnect = [prefs integerForKey:SETTINGS_NOTIFY_DISCONNECT];
    
    if(notifyDisconnect)
    {
        NSString *message = [NSString stringWithFormat:@"The BLE device '%@' has disconnected from the BLEduino app.", name];

        //Push local notification.
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody = message;
        notification.alertAction = nil;
        
        //Is application on the foreground?
        if([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)
        {
            //Application is on the foreground, store notification attributes to present alert view.
            notification.userInfo = @{@"title"  : @"BLEduino",
                                      @"message": message,
                                      @"disconnect": @"disconnect"};
        }
        
        //Present notification.
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

@end

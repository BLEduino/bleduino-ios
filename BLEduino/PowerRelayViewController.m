//
//  PowerRelayViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "PowerRelayViewController.h"
#import "BDLeDiscoveryManager.h"
#import "PowerNextStateView.h"
#import "BDBleduino.h"

@interface PowerRelayViewController ()
@property (strong) BDFirmataCommand *lastPowerSwitchCommand;
@property (weak) IBOutlet PowerSwitchButtonView *powerSwitch;
@property (weak) IBOutlet PowerNextStateView *otherStateIsOn;
@property (weak) IBOutlet PowerNextStateView *otherStateIsOff;
@property NSInteger pinNumber;
@end

@implementation PowerRelayViewController

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

    self.powerSwitch.delegate = self;
    self.otherStateIsOff.delegate = self;
    self.otherStateIsOn.delegate = self;
    
    //Update module based on settings.
    self.pinNumber = [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_POWERRELAY_PIN_NUMBER];
    
    //Set appareance.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIColor *lightBlue = [UIColor colorWithRed:THEME_COLOR_RED/255.0
                                         green:THEME_COLOR_GREEN/255.0
                                          blue:THEME_COLOR_BLUE/255.0
                                         alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = lightBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    [[UIScreen mainScreen] applicationFrame];
    
    //Manager Delegate
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    leManager.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissModule
{
    [self.delegate powerRelayModulViewControllerDismissed:self];
}

- (void)startPowerRelaySwitchViewWithStateOn:(BOOL)state
{
    CGRect newFrame;
    //Switch it On?
    if(state)
    {
        //Move it to top half position.
        newFrame = CGRectMake(10, 10, 300, 245);
    }
    else
    {
        //Move it to bottom half position.
        newFrame = CGRectMake(10, 250, 300, 245);
    }
    
    self.powerSwitch.frame = newFrame;
    self.isLastPowerRelayStateON = state;
}

- (void)updatePowerSwitchViewWithStateOn:(BOOL)state
{
    CGRect newFrame;
    //Switch it On?
    if(state)
    {
        //Move it to top half position.
        newFrame = CGRectMake(10, 10, 300, 245);
    }
    else
    {
        //Move it to bottom half position.
        newFrame = CGRectMake(10, 250, 300, 245);
    }

    //Execute view update.
    [UIView beginAnimations:@"Dragging Power Switch" context:nil];
    self.powerSwitch.frame = newFrame;
    [self.powerSwitch updatePowerSwitchTextWithStateOn:state];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
}

//Power Switch Delegate
- (void)powerSwitchDidUpdateWithStateOn:(BOOL)state
{
    //If the state remains the same do not re-send the data.
    if(self.isLastPowerRelayStateON == state)return;
    self.isLastPowerRelayStateON = state;
    
    //Create firmata command.
    BDFirmataCommand *powerSwitchCommand = [[BDFirmataCommand alloc] init];
    powerSwitchCommand.pinState = FirmataCommandPinStateOutput;
    powerSwitchCommand.pinValue = (state)?255:0; //255 > High, 0 > Low
    powerSwitchCommand.pinNumber = _pinNumber;
    _lastPowerSwitchCommand = powerSwitchCommand;

    //Send command.
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        BDFirmata *firmataService = [[BDFirmata alloc] initWithPeripheral:bleduino delegate:self];
        [firmataService writeFirmataCommand:powerSwitchCommand];
    }
    
    NSLog(@"Sent PowerRelay update, PinValue: %ld, PinNumber: %ld, PinState: %ld",
          (long)_lastPowerSwitchCommand.pinValue,
          (long)_lastPowerSwitchCommand.pinNumber,
          (long)_lastPowerSwitchCommand.pinState);
}

//Power Other State Delegate
- (void)powerOtherStateDidUpdateWithStateOn:(BOOL)state
{
    //User tocuhed the other state label instead of dragging the switch.
    //Update switch view i.e. move it, and then send firmata command.
    [self updatePowerSwitchViewWithStateOn:state];
    [self powerSwitchDidUpdateWithStateOn:state];
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

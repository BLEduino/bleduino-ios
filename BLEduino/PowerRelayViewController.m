//
//  PowerRelayViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "PowerRelayViewController.h"
#import "LeDiscoveryManager.h"

@implementation PowerRelayViewController
{
    FirmataCommandCharacteristic *_lastPowerSwitchCommand;
    IBOutlet PowerSwitchButtonView *powerSwitch;
    
    NSInteger _pinNumber;
}

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

    powerSwitch.delegate = self;
    
    //Update module based on settings.
    _pinNumber = [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_POWERRELAY_PIN_NUMBER];
    
    //Set appareance.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIColor *lightBlue = [UIColor colorWithRed:38/255.0 green:109/255.0 blue:235/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = lightBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    [[UIScreen mainScreen] applicationFrame];
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

- (void)powerSwitchDidUpdateWithStateOn:(BOOL)state
{
    //Create firmata command.
    FirmataCommandCharacteristic *powerSwitchCommand = [[FirmataCommandCharacteristic alloc] init];
    powerSwitchCommand.pinState = FirmataCommandPinStateOutput;
    powerSwitchCommand.pinValue = (state)?255:0; //255 > High, 0 > Low
    powerSwitchCommand.pinNumber = _pinNumber;
    _lastPowerSwitchCommand = powerSwitchCommand;

    //Send command.
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        FirmataService *firmataService = [[FirmataService alloc] initWithPeripheral:bleduino controller:self];
        [firmataService writeFirmataCommand:powerSwitchCommand];
    }

    NSLog(@"Sent PowerRelay update, PinValue: %ld, PinNumber: %ld, PinState: %ld",
          (long)_lastPowerSwitchCommand.pinValue,
          (long)_lastPowerSwitchCommand.pinNumber,
          (long)_lastPowerSwitchCommand.pinState);
}

@end

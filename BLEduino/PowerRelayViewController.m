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

@interface PowerRelayViewController ()
@property (strong) BDFirmataCommandCharacteristic *lastPowerSwitchCommand;
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
    //Create firmata command.
    BDFirmataCommandCharacteristic *powerSwitchCommand = [[BDFirmataCommandCharacteristic alloc] init];
    powerSwitchCommand.pinState = FirmataCommandPinStateOutput;
    powerSwitchCommand.pinValue = (state)?255:0; //255 > High, 0 > Low
    powerSwitchCommand.pinNumber = _pinNumber;
    _lastPowerSwitchCommand = powerSwitchCommand;

    //Send command.
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        BDFirmataService *firmataService = [[BDFirmataService alloc] initWithPeripheral:bleduino delegate:self];
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

@end

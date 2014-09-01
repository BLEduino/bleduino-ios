//
//  PowerRelayViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "PowerRelayViewController.h"
#import "BDLeManager.h"
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
    BDFirmataCommand *switchUpdate = [BDFirmataCommand command];
    switchUpdate.pinState = FirmataCommandPinStateOutput;
    switchUpdate.pinValue = (state)?255:0; //255 > High, 0 > Low
    switchUpdate.pinNumber = _pinNumber;
    _lastPowerSwitchCommand = switchUpdate;

    //Send command.
    BDLeManager *leManager = [BDLeManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {        
        [BDBleduino writeValue:switchUpdate bleduino:bleduino];
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

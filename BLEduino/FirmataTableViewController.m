//
//  FirmataTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 12/12/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "FirmataTableViewController.h"
#import "BDLeManager.h"
#import "BDFirmataCommand.h"

#import "FirmataAnalogCell.h"
#import "FirmataDigitalCell.h"
#import "FirmataPWMCell.h"


@interface FirmataTableViewController ()

@end

@implementation FirmataTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    BDLeManager *leManager = [BDLeManager sharedLeManager];
    CBPeripheral *bleduino = [leManager.connectedBleduinos lastObject];
    
    //Global firmata service for listening for updates.
    self.firmata =[BDBleduino bleduino:bleduino delegate:self];
    [self.firmata subscribe:Firmata notify:YES];
    
    //Load previous state.
    [self setPreviousState];
}

- (IBAction)dismissModule
{
    [self.delegate firmataTableViewControllerDismissed:self];
}

- (void)setPreviousState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    FirmataCommandPinState state = [defaults integerForKey:FIRMATA_PIN0_STATE];
    NSInteger value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin0 = [[BDFirmataCommand alloc] initWithPinState:state
                                                              pinNumber:0
                                                               pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN1_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin1 = [[BDFirmataCommand alloc] initWithPinState:state
                                                              pinNumber:1
                                                               pinValue:value];
 
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN2_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin2 = [[BDFirmataCommand alloc] initWithPinState:state
                                                              pinNumber:2
                                                               pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN3_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin3 = [[BDFirmataCommand alloc] initWithPinState:state
                                                              pinNumber:3
                                                               pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN4_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin4 = [[BDFirmataCommand alloc] initWithPinState:state
                                                              pinNumber:4
                                                               pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN5_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin5 = [[BDFirmataCommand alloc] initWithPinState:state
                                                              pinNumber:5
                                                               pinValue:value];

    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN6_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin6 = [[BDFirmataCommand alloc] initWithPinState:state
                                                              pinNumber:6
                                                               pinValue:value];

    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN7_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin7 = [[BDFirmataCommand alloc] initWithPinState:state
                                                              pinNumber:7
                                                               pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN8_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin8 = [[BDFirmataCommand alloc] initWithPinState:state
                                                              pinNumber:8
                                                               pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN9_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin9 = [[BDFirmataCommand alloc] initWithPinState:state
                                                              pinNumber:9
                                                               pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN10_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin10 = [[BDFirmataCommand alloc] initWithPinState:state
                                                               pinNumber:10
                                                                pinValue:value];
    
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN13_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pin13 = [[BDFirmataCommand alloc] initWithPinState:state
                                                               pinNumber:13
                                                                pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PINA0_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pinA0 = [[BDFirmataCommand alloc] initWithPinState:state
                                                               pinNumber:18
                                                                pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PINA1_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pinA1 = [[BDFirmataCommand alloc] initWithPinState:state
                                                               pinNumber:19
                                                                pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PINA2_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pinA2 = [[BDFirmataCommand alloc] initWithPinState:state
                                                               pinNumber:20
                                                                pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PINA3_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pinA3 = [[BDFirmataCommand alloc] initWithPinState:state
                                                               pinNumber:21
                                                                pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PINA4_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pinA4 = [[BDFirmataCommand alloc] initWithPinState:state
                                                               pinNumber:22
                                                                pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PINA5_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pinA5 = [[BDFirmataCommand alloc] initWithPinState:state
                                                               pinNumber:23
                                                                pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN_MISO_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pinMISO = [[BDFirmataCommand alloc] initWithPinState:state
                                                                 pinNumber:14
                                                                  pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN_MOSI_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pinMOSI = [[BDFirmataCommand alloc] initWithPinState:state
                                                                 pinNumber:16
                                                                  pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN_SCK_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommand *pinSCK = [[BDFirmataCommand alloc] initWithPinState:state
                                                                pinNumber:15
                                                                 pinValue:value];
    
    self.commands = @[pin0, pin1, pin2, pin3, pin4, pin5, pin6, pin7, pin8, pin9, pin10, pin13,
                      pinA0, pinA1, pinA2, pinA3, pinA4, pinA5, pinMISO, pinMOSI, pinSCK];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.commands count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BDFirmataCommand *firmataCommand = [self.commands objectAtIndex:indexPath.row];
    NSInteger index = indexPath.row;
    
    //PWM State
    if(firmataCommand.pinState == FirmataCommandPinStatePWM)
    {
        FirmataPWMCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PwmStateCell" forIndexPath:indexPath];
        cell.pinNumber.text = [FirmataTableViewController firmataPinNames:index];
        cell.pinState.attributedText = [FirmataTableViewController firmataPinTypesString:index
                                                                             forPinState:firmataCommand.pinState];
        [cell.pinValue addTarget:self
                          action:@selector(pwmUpdate:)
                forControlEvents:UIControlEventTouchUpInside];
        cell.secondPinValue.text = [NSString stringWithFormat:@"%ld", (long)firmataCommand.pinValue];
        cell.pinValue.tag = indexPath.row;
        return cell;
    }
    //Analog State
    else if(firmataCommand.pinState == FirmataCommandPinStateAnalog)
    {
        FirmataAnalogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnalogStateCell" forIndexPath:indexPath];
        cell.pinNumber.text = [FirmataTableViewController firmataPinNames:index];
        cell.pinState.attributedText = [FirmataTableViewController firmataPinTypesString:index
                                                                             forPinState:firmataCommand.pinState];
        if(firmataCommand.pinValue >= 0)
        {
            cell.pinValue.text = [NSString stringWithFormat:@"%ld", (long)firmataCommand.pinValue];
        }
        else
        {
            cell.pinValue.text = @"…";
            
        }
        
        cell.pinValue.tag = indexPath.row;
        return cell;
    }
    //Digital Out State
    if(firmataCommand.pinState == FirmataCommandPinStateOutput)
    {
        FirmataDigitalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DigitalStateCell" forIndexPath:indexPath];
        cell.pinNumber.text = [FirmataTableViewController firmataPinNames:index];
        cell.pinState.attributedText = [FirmataTableViewController firmataPinTypesString:index
                                                                             forPinState:firmataCommand.pinState];
        [cell.pinValue addTarget:self
                          action:@selector(digitalSwitchToggled:)
                forControlEvents:UIControlEventTouchUpInside];
        [cell.pinValue setOn:firmataCommand.pinValue];
        cell.pinValue.tag = indexPath.row;
        return cell;
    }
    //Digital In State
    else
    {
        FirmataAnalogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnalogStateCell" forIndexPath:indexPath];
        cell.pinNumber.text = [FirmataTableViewController firmataPinNames:index];
        cell.pinState.attributedText = [FirmataTableViewController firmataPinTypesString:index
                                                                             forPinState:firmataCommand.pinState];
        if(firmataCommand.pinValue >= 0)
        {
            cell.pinValue.text = [NSString stringWithFormat:@"%ld", (long)firmataCommand.pinValue];
        }
        else
        {
            cell.pinValue.text = @"…";

        }
        
        cell.pinValue.tag = indexPath.row;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Save new pin state for persistance.
    NSInteger index = indexPath.row;
    NSInteger types = [FirmataTableViewController firmataPinTypes:index];
    
    UIActionSheet *actionSheet;
    switch (types) {
        case 0:
        {
            NSString *pinName = [FirmataTableViewController firmataPinNames:index];
            NSString *message = [NSString stringWithFormat:@"Select state for %@", pinName];
            actionSheet = [[UIActionSheet alloc]
                           initWithTitle:message
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"Digital-Out", @"Digital-In", nil];
        }
            break;
            
        case 1:
        {
            NSString *pinName = [FirmataTableViewController firmataPinNames:index];
            NSString *message = [NSString stringWithFormat:@"Select state for %@", pinName];
            actionSheet = [[UIActionSheet alloc]
                           initWithTitle:message
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"Digital-Out", @"Digital-In", @"Analog", nil];
        }
            break;
            
        case 2:
        {
            NSString *pinName = [FirmataTableViewController firmataPinNames:index];
            NSString *message = [NSString stringWithFormat:@"Select state for %@", pinName];
            actionSheet = [[UIActionSheet alloc]
                           initWithTitle:message
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"Digital-Out", @"Digital-In", @"PWM", nil];
        }
            break;
            
        case 3:
        {
            NSString *pinName = [FirmataTableViewController firmataPinNames:index];
            NSString *message = [NSString stringWithFormat:@"Select state for %@", pinName];
            actionSheet = [[UIActionSheet alloc]
                           initWithTitle:message
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"Digital-Out", @"Digital-In", @"Analog", @"PWM", nil];
        }
            break;
    }
    
    //Show pin options.
    actionSheet.tag = (200 + index);
    [actionSheet showInView:self.view];
}

#pragma mark -
#pragma mark - Pin Updates Delegates
/****************************************************************************/
/*                             Pin Updates Delegates                        */
/****************************************************************************/
- (void) pwmUpdate:(id)sender
{
    UIButton *pinValue = (UIButton *)sender;
    UIAlertView *pwmValue = [[UIAlertView alloc] initWithTitle:@"PWM Value"
                                                      message:@"Please enter the PWM value."
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Done", nil];
    
    pwmValue.alertViewStyle = UIAlertViewStylePlainTextInput;
    pwmValue.tag = pinValue.tag;
    [pwmValue textFieldAtIndex:0].delegate = self;
    [pwmValue show];
}

//Digital-Out
- (void) digitalSwitchToggled:(id)sender
{
    UISwitch *digitalValue = (UISwitch *)sender;
    
    //Update firmata command.
    BDFirmataCommand *digitalSwitch = (BDFirmataCommand *)[self.commands objectAtIndex:digitalValue.tag];
    digitalSwitch.pinValue = digitalValue.on;
    
    if(!self.sync.isEnabled) //If Sync is disabled, i.e. sync has begun
    {
        //Send commands.
        [BDBleduino writeValue:digitalSwitch];
    }
}

//PWM
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Update PWM value.
    if(buttonIndex == 1) //Done button.
    {
        NSInteger pwmValue = [[alertView textFieldAtIndex:0].text integerValue];
        
        if(pwmValue >= 0 && pwmValue <= 255)
        {
            //Update firmata command.
            BDFirmataCommand *pwmCommand = (BDFirmataCommand *)[self.commands objectAtIndex:alertView.tag];
            pwmCommand.pinValue = pwmValue;
            
            if(!self.sync.isEnabled) //If Sync is disabled, i.e. sync has begun
            {
                [BDBleduino writeValue:pwmCommand];
            }
            
            [self.tableView reloadData];
        }
        else
        {
            UIAlertView *pwmValue = [[UIAlertView alloc] initWithTitle:@"PWM Value"
                                                               message:@"PWM values must be between 0 and 255"
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"Ok", nil];
            
            [pwmValue show];
        }
    }
}

//Analog and Digital-In
- (void)  firmataService:(BDFirmata *)service
didReceiveFirmataCommand:(BDFirmataCommand *)firmataCommand
                   error:(NSError *)error
{
    for(BDFirmataCommand *command in self.commands)
    {
        if(command.pinNumber == firmataCommand.pinNumber)
        {
            if(command.pinState == firmataCommand.pinState)
            {
                command.pinValue = firmataCommand.pinValue;
                [self.tableView reloadData];
            }
        }

    }
}

- (void) bleduino:(CBPeripheral *)bleduino didWriteValue:(id)data pipe:(BlePipe)pipe error:(NSError *)error
{
    if(pipe == Firmata)
    {
        NSLog(@"Did write to Firmata service.");
    }
}

//Analog and Digital-In
 - (void) bleduino:(CBPeripheral *)bleduino
    didUpdateValue:(id)data
              pipe:(BlePipe)pipe
             error:(NSError *)error
{
    if(error != nil && pipe == Firmata)
    {
        BDFirmataCommand *firmataCommand = (BDFirmataCommand *)data;
        
        for(BDFirmataCommand *command in self.commands)
        {
            if(command.pinNumber == firmataCommand.pinNumber)
            {
                if(command.pinState == firmataCommand.pinState)
                {
                    //Update value.
                    command.pinValue = firmataCommand.pinValue;
                    [self.tableView reloadData];
                }
            }
            
        }
    }
}

- (void) bleduino:(CBPeripheral *)bleduino didSubscribe:(BlePipe)pipe notify:(BOOL)notify error:(NSError *)error
{
    if(pipe == Firmata)
    {
        NSLog(@"Did subscribe to Firmata service.");
    }
}

//Changing PIN state.
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(buttonIndex < actionSheet.cancelButtonIndex)
    {
        NSInteger index = (actionSheet.tag - 200);
        NSInteger types = [FirmataTableViewController firmataPinTypes:index];
        
        BDFirmataCommand *pin = [self.commands objectAtIndex:index];
        switch (buttonIndex) {
            case 0:
                pin.pinState = FirmataCommandPinStateOutput;
                pin.pinValue = 0;
                break;
            case 1:
                pin.pinState = FirmataCommandPinStateInput;
                pin.pinValue = -1;
                break;
            case 2:
                if(types == 2)
                {
                    pin.pinState = FirmataCommandPinStatePWM;
                    pin.pinValue = 0;
                }
                else
                {
                    pin.pinState = FirmataCommandPinStateAnalog;
                    pin.pinValue = -1;
                }
                break;
            case 3:
                pin.pinState = FirmataCommandPinStatePWM;
                pin.pinValue = 0;
                break;
        }
        
        //Save new pin state for persistance.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        switch (index) {
            case 0:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN0_STATE];
                break;
                
            case 1:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN1_STATE];
                break;
                
            case 2:
                [defaults setInteger:pin.pinValue forKey:FIRMATA_PIN2_STATE];
                break;
                
            case 3:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN3_STATE];
                break;
                
            case 4:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN4_STATE];
                break;
                
            case 5:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN5_STATE];
                break;
                
            case 6:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN6_STATE];
                break;
                
            case 7:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN7_STATE];
                break;
                
            case 8:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN8_STATE];
                break;
                
            case 9:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN9_STATE];
                break;
                
            case 10:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN10_STATE];
                break;
                
            case 11:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN13_STATE];
                break;
                
            case 12:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PINA0_STATE];
                break;
                
            case 13:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PINA1_STATE];
                break;
                
            case 14:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PINA2_STATE];
                break;
                
            case 15:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PINA3_STATE];
                break;
                
            case 16:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PINA4_STATE];
                break;
                
            case 17:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PINA5_STATE];
                break;
                
            case 18:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN_MISO_STATE];
                break;
                
            case 19:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN_MOSI_STATE];
                break;
                
            case 20:
                [defaults setInteger:pin.pinState forKey:FIRMATA_PIN_SCK_STATE];
                break;
        }
        
        [defaults synchronize];
        
        if(!self.sync.isEnabled) //If Sync is disabled, i.e. sync has begun
        {
            [BDBleduino writeValue:pin];
        }
        [self.tableView reloadData];
    }
}

- (IBAction)sendData:(id)sender
{
    if(self.sync.isEnabled)
    {
        //Send commands.
        for(BDFirmataCommand *command in self.commands)
        {
            [BDBleduino writeValue:command];
            NSLog(@"Syncing...");
        }
    }

    self.sync.enabled = NO;
    NSLog(@"Firmata sync with the BLEduino has begun.");
}

- (IBAction)resetAllPins:(id)sender
{
    self.sync.enabled = YES;
    NSLog(@"Firmata sync with the BLEduino has been stopped.");
    
    //Reset pin state storage.
    NSInteger defaultState = 1;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN0_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN1_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN2_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN3_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN4_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN5_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN6_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN7_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN8_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN9_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN10_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN13_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PINA0_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PINA1_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PINA2_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PINA3_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PINA4_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PINA5_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN_MISO_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN_MOSI_STATE];
    [defaults setInteger:defaultState forKey:FIRMATA_PIN_SCK_STATE];
    [defaults synchronize];
    
    //Reset view.
    for(BDFirmataCommand *command in self.commands)
    {
        command.pinState = FirmataCommandPinStateInput;
        command.pinValue = -1;
    }

    [self.tableView reloadData];
}

+ (NSInteger) firmataPinTypes:(NSInteger)index
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger types = 0;
    switch (index) {
        case 0:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN0_STATE_TYPES];
            break;
            
        case 1:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN1_STATE_TYPES];
            break;
            
        case 2:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN2_STATE_TYPES];
            break;
            
        case 3:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN3_STATE_TYPES];
            break;
            
        case 4:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN4_STATE_TYPES];
            break;
            
        case 5:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN5_STATE_TYPES];
            break;
            
        case 6:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN6_STATE_TYPES];
            break;
            
        case 7:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN7_STATE_TYPES];
            break;
            
        case 8:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN8_STATE_TYPES];
            break;
            
        case 9:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN9_STATE_TYPES];
            break;
            
        case 10:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN10_STATE_TYPES];
            break;
            
        case 11:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN13_STATE_TYPES];
            break;
            
        case 12:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA0_STATE_TYPES];
            break;
            
        case 13:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA1_STATE_TYPES];
            break;
            
        case 14:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA2_STATE_TYPES];
            break;
            
        case 15:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA3_STATE_TYPES];
            break;
            
        case 16:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA4_STATE_TYPES];
            break;
            
        case 17:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA5_STATE_TYPES];
            break;
            
        case 18:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN_MISO_STATE_TYPES];
            break;
            
        case 19:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN_MOSI_STATE_TYPES];
            break;
            
        case 20:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN_SCK_STATE_TYPES];
            break;
    }

    [defaults synchronize];
    return types;
}

+ (NSMutableAttributedString *) firmataPinTypesString:(NSInteger)index
                                          forPinState:(FirmataCommandPinState)state
{
    UIColor *selection = [UIColor colorWithRed:THEME_COLOR_RED/255.0
                                         green:THEME_COLOR_GREEN/255.0
                                          blue:THEME_COLOR_BLUE/255.0
                                         alpha:1.0];
    
    
    NSString *digital   = @"Digital-Out • Digital-In";
    NSString *analog    = @"Digital-Out • Digital-In • Analog";
    NSString *pwm       = @"Digital-Out • Digital-In • PWM";
    NSString *allTypes  = @"Digital-Out • Digital-In • Analog • PWM";
    NSString *rangeString;
    
    NSMutableAttributedString *types_String;
    NSInteger types = [FirmataTableViewController firmataPinTypes:index];
    switch (types) {
        case 0:
            types_String = [[NSMutableAttributedString alloc] initWithString:digital];
            rangeString = digital;
            break;
        case 1:
            types_String = [[NSMutableAttributedString alloc] initWithString:analog];
            rangeString = analog;
            break;
        case 2:
            types_String = [[NSMutableAttributedString alloc] initWithString:pwm];
            rangeString = pwm;
            break;
        case 3:
            types_String = [[NSMutableAttributedString alloc] initWithString:allTypes];
            rangeString = allTypes;
            break;
    }

    switch ((NSInteger)state) {
        case 0:
        {
            NSRange range = [rangeString rangeOfString:@"Digital-Out"];
            [types_String addAttribute:NSForegroundColorAttributeName value:selection range:range];
        }
            break;
        case 1:
        {
            NSRange range = [rangeString rangeOfString:@"Digital-In"];
            [types_String addAttribute:NSForegroundColorAttributeName value:selection range:range];
        }
            break;
        case 2:
        {
            NSRange range = [rangeString rangeOfString:@"Analog"];
            [types_String addAttribute:NSForegroundColorAttributeName value:selection range:range];

        }
            break;
        case 3:
        {
            NSRange range = [rangeString rangeOfString:@"PWM"];
            [types_String addAttribute:NSForegroundColorAttributeName value:selection range:range];
        }
            break;
    }
    return types_String;
}


+ (NSString *) firmataPinNames:(NSInteger)index
{
    NSString *name;
    if(index < 11)
    {
        name = [NSString stringWithFormat:@"Pin %ld", (long)index];
    }
    else
    {
        switch (index) {
            case 11:
                name = @"Pin 13";
                break;
            case 12:
                name = @"Pin A0";
                break;
            case 13:
                name = @"Pin A1";
                break;
            case 14:
                name = @"Pin A2";
                break;
            case 15:
                name = @"Pin A3";
                break;
            case 16:
                name = @"Pin A4";
                break;
            case 17:
                name = @"Pin A5";
                break;
            case 18:
                name = @"Pin MISO";
                break;
            case 19:
                name = @"Pin MOSI";
                break;
            case 20:
                name = @"Pin SCK";
                break;
                
        }
    }
    
    return name;
}

@end

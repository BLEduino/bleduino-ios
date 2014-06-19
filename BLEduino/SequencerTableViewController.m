//
//  SequencerTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 6/13/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "SequencerTableViewController.h"

@interface SequencerTableViewController ()

@end

@implementation SequencerTableViewController

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
    self.sequence = [NSMutableArray arrayWithCapacity:10];
    
    //Begin/End sequence commands. 
    self.start = [[BDFirmataCommandCharacteristic alloc] initWithPinState:4
                                                                pinNumber:99
                                                                 pinValue:99];
    
    self.end = [[BDFirmataCommandCharacteristic alloc] initWithPinState:5
                                                              pinNumber:99
                                                               pinValue:99];
    
    //Set appareance.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIColor *lightBlue = [UIColor colorWithRed:38/255.0 green:109/255.0 blue:235/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = lightBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    CBPeripheral *bleduino = [leManager.connectedBleduinos lastObject];
    
    //Global firmata service for listening for updates.
    self.firmata =[[BDFirmataService alloc] initWithPeripheral:bleduino delegate:self];
    [self.firmata subscribeToStartReceivingFirmataCommands];
    
    //Load previous state.
    [self setPreviousState];
}

- (IBAction)dismissModule
{
    [self.delegate sequencerTableViewControllerDismissed:self];
}

- (void)setPreviousState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    FirmataCommandPinState state = [defaults integerForKey:FIRMATA_PIN0_STATE];
    NSInteger value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommandCharacteristic *pin0 = [[BDFirmataCommandCharacteristic alloc] initWithPinState:state
                                                                                          pinNumber:0
                                                                                           pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN1_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommandCharacteristic *pin1 = [[BDFirmataCommandCharacteristic alloc] initWithPinState:state
                                                                                          pinNumber:1
                                                                                           pinValue:value];
    
    state = (NSUInteger)[defaults integerForKey:FIRMATA_PIN2_STATE];
    value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?0:-1;
    BDFirmataCommandCharacteristic *pin2 = [[BDFirmataCommandCharacteristic alloc] initWithPinState:state
                                                                                          pinNumber:2
                                                                                           pinValue:value];

    [self.sequence addObjectsFromArray:@[pin0, pin1, pin2]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//FIXME: Finish adding commands and delays.
- (IBAction)addCommand:(id)sender
{
    //Show pin options.
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Select Pin"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:
                                  @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7",
                                  @"8", @"9", @"10", @"13", @"A0", @"A1", @"A2",
                                  @"A3", @"A4", @"A5", @"MISO", @"MOSI", @"SCK", nil];
    
    actionSheet.tag = 2500;
    [actionSheet showFromBarButtonItem:self.addCommand animated:YES];
}

- (IBAction)addDelay:(id)sender
{
    BDFirmataCommandCharacteristic *delay =
    [[BDFirmataCommandCharacteristic alloc] initWithPinState:6
                                                   pinNumber:self.sequence.count
                                                    pinValue:1];
    
    [self.sequence addObject:delay];
    [self.tableView reloadData];
}

- (IBAction)editSequence:(id)sender
{
    if(self.tableView.isEditing)
    {
        [self.tableView setEditing:NO animated:YES];
        self.edit.title = @"Edit";
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        self.edit.title = @"Done";
    }
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.sequence.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BDFirmataCommandCharacteristic *firmataCommand = [self.sequence objectAtIndex:indexPath.row];

    //PWM State
    if(firmataCommand.pinState == FirmataCommandPinStatePWM)
    {
        FirmataPWMCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PwmStateCell" forIndexPath:indexPath];
        cell.pinNumber.text = [SequencerTableViewController firmataPinNames:firmataCommand.pinNumber];
        cell.pinState.attributedText = [SequencerTableViewController firmataPinTypesString:firmataCommand.pinNumber
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
        cell.pinNumber.text = [SequencerTableViewController firmataPinNames:firmataCommand.pinNumber];
        cell.pinState.attributedText = [SequencerTableViewController firmataPinTypesString:firmataCommand.pinNumber
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
    else if(firmataCommand.pinState == FirmataCommandPinStateOutput)
    {
        FirmataDigitalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DigitalStateCell" forIndexPath:indexPath];
        cell.pinNumber.text = [SequencerTableViewController firmataPinNames:firmataCommand.pinNumber];
        cell.pinState.attributedText = [SequencerTableViewController firmataPinTypesString:firmataCommand.pinNumber
                                                                             forPinState:firmataCommand.pinState];
        [cell.pinValue addTarget:self
                          action:@selector(digitalSwitchToggled:)
                forControlEvents:UIControlEventTouchUpInside];
        [cell.pinValue setOn:firmataCommand.pinValue];
        cell.pinValue.tag = indexPath.row;
        return cell;
    }
    //Digital In State
    else if(firmataCommand.pinState == FirmataCommandPinStateInput)
    {
        FirmataAnalogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnalogStateCell" forIndexPath:indexPath];
        cell.pinNumber.text = [SequencerTableViewController firmataPinNames:firmataCommand.pinNumber];
        cell.pinState.attributedText = [SequencerTableViewController firmataPinTypesString:firmataCommand.pinNumber
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
    else
    {
        FirmataPWMCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PwmStateCell" forIndexPath:indexPath];
        cell.pinNumber.text = @"Time Delay";
        cell.pinState.attributedText = [SequencerTableViewController firmataPinTypesString:firmataCommand.pinNumber
                                                                               forPinState:firmataCommand.pinState];
        [cell.pinValue addTarget:self
                          action:@selector(delayUpdate:)
                forControlEvents:UIControlEventTouchUpInside];
        cell.secondPinValue.text = [NSString stringWithFormat:@"%ld", (long)firmataCommand.pinValue];
        cell.pinValue.tag = indexPath.row;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Save new pin state for persistance.
    NSInteger index = indexPath.row;
    
    FirmataCommandPinState state = ((BDFirmataCommandCharacteristic *)[self.sequence objectAtIndex:index]).pinState;
    NSInteger types = (state > 3)?4:[SequencerTableViewController firmataPinTypes:index];
    
    UIActionSheet *actionSheet;
    switch (types) {
        case 0:
        {
            NSString *pinName = [SequencerTableViewController firmataPinNames:index];
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
            NSString *pinName = [SequencerTableViewController firmataPinNames:index];
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
            NSString *pinName = [SequencerTableViewController firmataPinNames:index];
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
            NSString *pinName = [SequencerTableViewController firmataPinNames:index];
            NSString *message = [NSString stringWithFormat:@"Select state for %@", pinName];
            actionSheet = [[UIActionSheet alloc]
                           initWithTitle:message
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"Digital-Out", @"Digital-In", @"Analog", @"PWM", nil];
        }
            break;
        case 4:
        {
            actionSheet = [[UIActionSheet alloc]
                           initWithTitle:@"Select delay type"
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"Seconds", @"Minutes", nil];
        }
            break;
    }
    
    //Show pin options.
    actionSheet.tag = (200 + index);
    [actionSheet showInView:self.view];
}

//Removing Commands
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //FIXME: remove from array.
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

//Sorting Commands
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    //FIXME: Move values in array.
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//FIXME: fix for having different indepath from pinNumbers, for update methods, helper methods and sending data back-and-forth.
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

- (void) delayUpdate:(id)sender
{
    UIButton *pinValue = (UIButton *)sender;
    UIAlertView *delayValue = [[UIAlertView alloc] initWithTitle:@"Time Delay Value"
                                                       message:@"Please enter the time delay value."
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Done", nil];
    
    delayValue.alertViewStyle = UIAlertViewStylePlainTextInput;
    delayValue.tag = pinValue.tag;
    [delayValue textFieldAtIndex:0].delegate = self;
    [delayValue show];
}

//Digital-Out
- (void) digitalSwitchToggled:(id)sender
{
    UISwitch *digitalValue = (UISwitch *)sender;
    
    //Update firmata command.
    BDFirmataCommandCharacteristic *digitalSwitchCommand = (BDFirmataCommandCharacteristic *)[self.sequence objectAtIndex:digitalValue.tag];
    digitalSwitchCommand.pinValue = digitalValue.on;
    
    //Send command.
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        BDFirmataService *firmataService = [[BDFirmataService alloc] initWithPeripheral:bleduino delegate:self];
        [firmataService writeFirmataCommand:digitalSwitchCommand];
    }
}

//PWM & Time Delay
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Update PWM value.
    if(buttonIndex == 1) //Done button.
    {
        NSInteger pwmValue = [[alertView textFieldAtIndex:0].text integerValue];
        
        if(pwmValue >= 0 && pwmValue <= 255)
        {
            //Update firmata command.
            BDFirmataCommandCharacteristic *pwmCommand = (BDFirmataCommandCharacteristic *)[self.sequence objectAtIndex:alertView.tag];
            pwmCommand.pinValue = pwmValue;

            [self.tableView reloadData];
        }
        else
        {
            UIAlertView *pwmValue = [[UIAlertView alloc] initWithTitle:@"Incorrect Value"
                                                               message:@"Value must be between 0 and 255"
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"Ok", nil];
            
            [pwmValue show];
        }
    }
}

//Analog and Digital-In
- (void)  firmataService:(BDFirmataService *)service
didReceiveFirmataCommand:(BDFirmataCommandCharacteristic *)firmataCommand
                   error:(NSError *)error
{
    BDFirmataCommandCharacteristic *command = [self.sequence objectAtIndex:firmataCommand.pinNumber];
    if(command.pinState == firmataCommand.pinState)
    {
        command.pinValue = firmataCommand.pinValue;
        [self.tableView reloadData];
    }
    
}

//Changing PIN state.
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex < actionSheet.cancelButtonIndex)
    {
        NSInteger index = (actionSheet.tag - 200);
        NSInteger types = [SequencerTableViewController firmataPinTypes:index];
        
        BDFirmataCommandCharacteristic *pin = [self.sequence objectAtIndex:index];
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
        [self.tableView reloadData];
    }
}

- (IBAction)sendSequence:(id)sender
{
    //Add begin/end commands to sequence.
    NSMutableArray *finalSequence = [NSMutableArray arrayWithArray:self.sequence];
    [finalSequence insertObject:self.start atIndex:0];
    [finalSequence insertObject:self.end atIndex:finalSequence.count];
    
    //Send command.
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        for(BDFirmataCommandCharacteristic *command in finalSequence)
        {
            BDFirmataService *firmataService = [[BDFirmataService alloc] initWithPeripheral:bleduino delegate:self];
            [firmataService writeFirmataCommand:command];
        }
    }
}

//Helper Methods
+ (NSInteger) firmataPinTypes:(NSInteger)pinNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger types = 0;
    switch (pinNumber) {
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

+ (NSMutableAttributedString *) firmataPinTypesString:(NSInteger)pinNumber
                                          forPinState:(FirmataCommandPinState)state
{
    UIColor *selection = [UIColor colorWithRed:38/255.0 green:109/255.0 blue:235/255.0 alpha:1.0];
    NSString *digital   = @"Digital-Out • Digital-In";
    NSString *analog    = @"Digital-Out • Digital-In • Analog";
    NSString *pwm       = @"Digital-Out • Digital-In • PWM";
    NSString *allTypes  = @"Digital-Out • Digital-In • Analog • PWM";
    NSString *delay     = @"Seconds • Minutes";
    NSString *rangeString;
    
    NSMutableAttributedString *types_String;
    NSInteger types = (state > 3)?4:[SequencerTableViewController firmataPinTypes:pinNumber];
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
        case 4:
            types_String = [[NSMutableAttributedString alloc] initWithString:delay];
            rangeString = delay;
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
        case 6:
        {
            NSRange range = [rangeString rangeOfString:@"Seconds"];
            [types_String addAttribute:NSForegroundColorAttributeName value:selection range:range];
        }
            break;
        case 7:
        {
            NSRange range = [rangeString rangeOfString:@"Minutes"];
            [types_String addAttribute:NSForegroundColorAttributeName value:selection range:range];
        }
            break;
    }
    return types_String;
}


+ (NSString *) firmataPinNames:(NSInteger)pinNumber
{
    NSString *name;
    if(pinNumber < 12)
    {
        if(pinNumber == 11) pinNumber = pinNumber+2; //Fix for pin 13.
        name = [NSString stringWithFormat:@"Pin %ld", (long)pinNumber];
    }
    else
    {
        switch (pinNumber) {
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

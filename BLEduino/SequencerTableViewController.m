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
    self.start = [[BDFirmataCommand alloc] initWithPinState:4
                                                  pinNumber:99
                                                   pinValue:99];
    
    self.end = [[BDFirmataCommand alloc] initWithPinState:5
                                                pinNumber:99
                                                 pinValue:99];
    
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
    
    self.edit.tintColor = lightBlue;
    self.addCommand.tintColor = lightBlue;
    self.addDelay.tintColor = lightBlue;
    
    BDLeManager *leManager = [BDLeManager sharedLeManager];
    CBPeripheral *bleduino = [leManager.connectedBleduinos lastObject];
    
    //Global firmata service for listening for updates.
    self.firmata =[BDBleduino bleduino:bleduino delegate:self];
    [self.firmata subscribe:Firmata notify:YES];
    
    //Load previous state.
    [self setPreviousState];
}

- (void)viewDidLayoutSubviews
{
    [self.tableView headerViewForSection:0].textLabel.textAlignment = NSTextAlignmentCenter;
}

- (IBAction)dismissModule
{
    //Store sequence for persistance.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *sequence = [[NSMutableArray alloc] initWithCapacity:self.sequence.count];
    NSMutableArray *sequenceStates = [[NSMutableArray alloc] initWithCapacity:self.sequence.count];
    NSMutableArray *sequenceValues = [[NSMutableArray alloc] initWithCapacity:self.sequence.count];
    NSMutableArray *sequenceDelayFormats = [[NSMutableArray alloc] initWithCapacity:self.sequence.count];
    NSMutableArray *sequenceDelayValues = [[NSMutableArray alloc] initWithCapacity:self.sequence.count];
    

    for (BDFirmataCommand *command in self.sequence)
    {
        [sequence addObject:[NSNumber numberWithLong:command.pinNumber]];
        
        //Store delay configuration.
        if(command.pinNumber == 100)
        {
            [sequenceDelayFormats addObject:[NSNumber numberWithLong:command.pinState]];
            [sequenceDelayValues addObject:[NSNumber numberWithLong:command.pinValue]];
        }
        else
        {
            [sequenceStates addObject:[NSNumber numberWithLong:command.pinState]];
            [sequenceValues addObject:[NSNumber numberWithLong:command.pinValue]];
        }
    }
    
    //Archive everything.
    [defaults setObject:sequence             forKey:SEQUENCE];
    [defaults setObject:sequenceStates       forKey:SEQUENCE_STATES];
    [defaults setObject:sequenceValues       forKey:SEQUENCE_VALUES];
    [defaults setObject:sequenceDelayFormats forKey:SEQUENCE_DELAY_FORMATS];
    [defaults setObject:sequenceDelayValues  forKey:SEQUENCE_DELAY_VALUES];
    [defaults synchronize];
    
    [self.delegate sequencerTableViewControllerDismissed:self];
}

- (void)setPreviousState
{
    //Load sequence.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *sequence = (NSArray *)[defaults objectForKey:SEQUENCE];
    NSArray *sequenceStates = (NSArray *)[defaults objectForKey:SEQUENCE_STATES];
    NSArray *sequenceValues = (NSArray *)[defaults objectForKey:SEQUENCE_VALUES];
    NSArray *sequenceDelayFormats = (NSArray *)[defaults objectForKey:SEQUENCE_DELAY_FORMATS];
    NSArray *sequenceDelayValues = (NSArray *)[defaults objectForKey:SEQUENCE_DELAY_VALUES];
    NSInteger delayCounter = 0;
    NSInteger pinCounter = 0;
    
    self.sequence = [[NSMutableArray alloc] initWithCapacity:sequence.count];
    
    for (NSNumber *entry in sequence)
    {
        NSInteger command = [entry intValue];
        if(command <= 23)
        {
            FirmataCommandPinState state = [[sequenceStates objectAtIndex:pinCounter] intValue];
            NSInteger storedValue = [[sequenceValues objectAtIndex:pinCounter] intValue];
            NSInteger value = (state == FirmataCommandPinStatePWM || state == FirmataCommandPinStateOutput)?storedValue:-1;
            BDFirmataCommand *pin = [[BDFirmataCommand alloc] initWithPinState:state
                                                                                                 pinNumber:command
                                                                                                  pinValue:value];
            [self.sequence addObject:pin];
            pinCounter = pinCounter + 1;
        }
        else
        {
            NSInteger delayFormat = [[sequenceDelayFormats objectAtIndex:delayCounter] intValue];
            NSInteger delayValue = [[sequenceDelayValues objectAtIndex:delayCounter] intValue];
            delayCounter = delayCounter + 1;
            
            BDFirmataCommand *delay = [[BDFirmataCommand alloc] initWithPinState:delayFormat
                                                                                                   pinNumber:100
                                                                                                    pinValue:delayValue];
            [self.sequence addObject:delay];
        }
    }

    [defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    
    actionSheet.tag = 300;
    [actionSheet showFromBarButtonItem:[self.toolbarItems objectAtIndex:2] animated:YES];
}

- (IBAction)addDelay:(id)sender
{
    BDFirmataCommand *delay =
    [[BDFirmataCommand alloc] initWithPinState:6
                                                   pinNumber:100
                                                    pinValue:1];
    
    [self.sequence addObject:delay];
    [self.tableView reloadData];
}

- (void) deleteSequence:(id)sender
{
    [self.sequence removeAllObjects];
    [self.tableView setEditing:NO animated:YES];
    [self.tableView reloadData];
    
    UIColor *lightBlue = [UIColor colorWithRed:THEME_COLOR_RED/255.0
                                         green:THEME_COLOR_GREEN/255.0
                                          blue:THEME_COLOR_BLUE/255.0
                                         alpha:1.0];
    
    UIBarButtonItem *delay = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delay.png"]
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(addDelay:)];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addCommand:)];
    
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                          target:self
                                                                          action:@selector(editSequence:)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
    
    delay.tintColor = add.tintColor = edit.tintColor = lightBlue;
    [self setToolbarItems:@[delay, space, add, space, edit]];
}

- (IBAction)editSequence:(id)sender
{
    UIColor *lightBlue = [UIColor colorWithRed:THEME_COLOR_RED/255.0
                                         green:THEME_COLOR_GREEN/255.0
                                          blue:THEME_COLOR_BLUE/255.0
                                         alpha:1.0];
    
    if(self.tableView.isEditing)
    {
        [self.tableView setEditing:NO animated:YES];
        UIBarButtonItem *delay = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delay.png"]
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(addDelay:)];

        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addCommand:)];
        
        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                              target:self
                                                                              action:@selector(editSequence:)];
        
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
        
        add.tintColor = delay.tintColor = edit.tintColor = lightBlue;
        [self setToolbarItems:@[delay, space, add, space, edit]];
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                               target:self
                                                                               action:@selector(deleteSequence:)];
        
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(editSequence:)];
        
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
        
        trash.tintColor = done.tintColor = lightBlue;
        [self setToolbarItems:@[space, trash, space, done]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.sequence.count == 0)
    {
        return 100;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.sequence.count == 0)
    {
        return @"No sequence\n\n\nAdd a command to start a new sequence";
    }
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.sequence.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BDFirmataCommand *firmataCommand = [self.sequence objectAtIndex:indexPath.row];

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
    //Time delay.
    else
    {
        TimeDelayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeDelayCell" forIndexPath:indexPath];
        cell.delayName.text = @"Time Delay";
        cell.delayFormat.attributedText = [SequencerTableViewController firmataPinTypesString:firmataCommand.pinNumber
                                                                                  forPinState:firmataCommand.pinState];
        [cell.delayValue addTarget:self
                            action:@selector(delayUpdate:)
                  forControlEvents:UIControlEventTouchUpInside];
        cell.secondDelayValue.text = [NSString stringWithFormat:@"%ld", (long)firmataCommand.pinValue];
        cell.delayValue.tag = indexPath.row;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Save new pin state for persistance.
    BDFirmataCommand *pin = (BDFirmataCommand *)[self.sequence objectAtIndex:indexPath.row];
    NSInteger pinNumber = pin.pinNumber;

    FirmataCommandPinState state = pin.pinState;
    NSInteger types = (state > 3)?4:[SequencerTableViewController firmataPinTypes:pinNumber];
    
    UIColor *lightBlue = [UIColor colorWithRed:THEME_COLOR_RED/255.0
                                         green:THEME_COLOR_GREEN/255.0
                                          blue:THEME_COLOR_BLUE/255.0
                                         alpha:1.0];
    
    UIActionSheet *actionSheet;
    switch (types) {
        case 0:
        {
            NSString *pinName = [SequencerTableViewController firmataPinNames:pinNumber];
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
            NSString *pinName = [SequencerTableViewController firmataPinNames:pinNumber];
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
            NSString *pinName = [SequencerTableViewController firmataPinNames:pinNumber];
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
            NSString *pinName = [SequencerTableViewController firmataPinNames:pinNumber];
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
    
    //Show pin/delay options.
    actionSheet.tag = (types > 3)?(400 + indexPath.row):(200 + indexPath.row);
    actionSheet.tintColor = lightBlue;
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
        [self.sequence removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

//Sorting Commands
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    BDFirmataCommand *command = [self.sequence objectAtIndex:fromIndexPath.row];
    [self.sequence removeObjectAtIndex:fromIndexPath.row];
    [self.sequence insertObject:command atIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
    BDFirmataCommand *digitalSwitchCommand = (BDFirmataCommand *)[self.sequence objectAtIndex:digitalValue.tag];
    digitalSwitchCommand.pinValue = digitalValue.on;
    
    //Send command.
    BDLeManager *leManager = [BDLeManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        BDFirmata *firmataService = [[BDFirmata alloc] initWithPeripheral:bleduino delegate:self];
        [firmataService writeFirmataCommand:digitalSwitchCommand];
    }
}

//PWM & Time Delay
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Update PWM value.
    if(buttonIndex == 1 && alertView.tag != 815) //Done button.
    {
        NSInteger pwmValue = [[alertView textFieldAtIndex:0].text integerValue];
        
        if(pwmValue >= 0 && pwmValue <= 255)
        {
            //Update firmata command.
            BDFirmataCommand *pwmCommand = (BDFirmataCommand *)[self.sequence objectAtIndex:alertView.tag];
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
- (void)  firmataService:(BDFirmata *)service
didReceiveFirmataCommand:(BDFirmataCommand *)firmataCommand
                   error:(NSError *)error
{
    //Update data to all pins that it applies to.
    for(BDFirmataCommand *pin in self.sequence)
    {
        if(pin.pinNumber == firmataCommand.pinNumber &&
           pin.pinState == firmataCommand.pinState)
        {
            pin.pinValue = firmataCommand.pinValue;
        }
    }
    
    [self.tableView reloadData];
}


- (void) bleduino:(CBPeripheral *)bleduino didWriteValue:(id)data pipe:(BlePipe)pipe error:(NSError *)error
{
    NSLog(@"Did write to Firmata service");
}

- (void) bleduino:(CBPeripheral *)bleduino didUpdateValue:(id)data pipe:(BlePipe)pipe error:(NSError *)error
{
    BDFirmataCommand *firmataCommand = (BDFirmataCommand *)data;
    
    //Update data to all pins that it applies to.
    for(BDFirmataCommand *pin in self.sequence)
    {
        if(pin.pinNumber == firmataCommand.pinNumber &&
           pin.pinState == firmataCommand.pinState)
        {
            pin.pinValue = firmataCommand.pinValue;
        }
    }
    
    [self.tableView reloadData];
}

- (void) bleduino:(CBPeripheral *)bleduino didSubscribe:(BlePipe)pipe notify:(BOOL)notify error:(NSError *)error
{
    NSLog(@"Did subscribe to Firmata service");
}

//Changing PIN state.
//Sequence is stored in full (pin values and states, time delays, and their order) before user leaves this module.
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex < actionSheet.cancelButtonIndex)
    {
        //******************************************
        //***** Update pin state / Add new pin *****
        //******************************************
        if(actionSheet.tag < 400)
        {
            //**********************
            //***** Update pin *****
            //**********************
            if(actionSheet.tag < 300)
            {
                NSInteger index = (actionSheet.tag - 200);
                BDFirmataCommand *pin = (BDFirmataCommand *)[self.sequence objectAtIndex:index];
                NSInteger pinNumber = pin.pinNumber;
                NSInteger types = [SequencerTableViewController firmataPinTypes:pinNumber];
        
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
            }
            
            //***********************
            //***** Add new pin *****
            //***********************
            else
            {
                NSInteger pinNumber = [self pinNumber:buttonIndex];
                BDFirmataCommand *pin = [[BDFirmataCommand alloc] initWithPinState:1
                                                                                                     pinNumber:pinNumber
                                                                                                      pinValue:-1];
                
                [self.sequence insertObject:pin atIndex:self.sequence.count];

            }
        }
        //*****************************
        //***** Update time-delay *****
        //*****************************
        else
        {
            NSInteger index = (actionSheet.tag - 400);
            BDFirmataCommand *delay = [self.sequence objectAtIndex:index];
            delay.pinState = 6 + buttonIndex;
        }
 
        //Update view.
        [self.tableView reloadData];
    }
}

- (IBAction)sendSequence:(id)sender
{
    if(self.sequence.count <= 18)
    {
        //Add begin/end commands to sequence.
        NSMutableArray *finalSequence = [NSMutableArray arrayWithArray:self.sequence];
        [finalSequence insertObject:self.start atIndex:0];
        [finalSequence insertObject:self.end atIndex:finalSequence.count];
        
        //Send command.
        for(BDFirmataCommand *command in finalSequence)
        {
            [BDBleduino writeValue:command];
        }
    }
    else
    {
        NSString *message = @"Due to limited memory on the BLEduino, the sequence must be 18 commands or less.";
        UIAlertView *sequenceAlert = [[UIAlertView alloc]initWithTitle:@"Sequence is too long"
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
        sequenceAlert.tag = 815;
        [sequenceAlert show];
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
            
        case 13:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN13_STATE_TYPES];
            break;
            
        case 14:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN_MISO_STATE_TYPES];
            break;
        
        case 15:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN_SCK_STATE_TYPES];
            break;
        
        case 16:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PIN_MOSI_STATE_TYPES];
            break;
            
        case 18:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA0_STATE_TYPES];
            break;
            
        case 19:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA1_STATE_TYPES];
            break;
            
        case 20:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA2_STATE_TYPES];
            break;
            
        case 21:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA3_STATE_TYPES];
            break;
            
        case 22:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA4_STATE_TYPES];
            break;
            
        case 23:
            types = (NSInteger)[defaults integerForKey:FIRMATA_PINA5_STATE_TYPES];
            break;
    }
    
    [defaults synchronize];
    return types;
}

+ (NSMutableAttributedString *) firmataPinTypesString:(NSInteger)pinNumber
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
    if(pinNumber < 11)
    {
        name = [NSString stringWithFormat:@"Pin %ld", (long)pinNumber];
    }
    else
    {
        switch (pinNumber) {
            case 13:
                name = @"Pin 13";
                break;
            case 14:
                name = @"Pin MISO";
                break;
            case 15:
                name = @"Pin SCK";
                break;
            case 16:
                name = @"Pin MOSI";
                break;
            case 18:
                name = @"Pin A0";
                break;
            case 19:
                name = @"Pin A1";
                break;
            case 20:
                name = @"Pin A2";
                break;
            case 21:
                name = @"Pin A3";
                break;
            case 22:
                name = @"Pin A4";
                break;
            case 23:
                name = @"Pin A5";
                break;
        }
    }
    
    return name;
}

- (NSInteger) pinNumber:(NSInteger)selection
{
    NSInteger pin;
    switch (selection) {
        case 0:
            pin = 0;
            break;
        case 1:
            pin = 1;
            break;
        case 2:
            pin = 2;
            break;
        case 3:
            pin = 3;
            break;
        case 4:
            pin = 4;
            break;
        case 5:
            pin = 5;
            break;
        case 6:
            pin = 6;
            break;
        case 7:
            pin = 7;
            break;
        case 8:
            pin = 8;
            break;
        case 9:
            pin = 9;
            break;
        case 10:
            pin = 10;
            break;
        case 11:
            pin = 13;
            break;
        case 12:
            pin = 18;
            break;
        case 13:
            pin = 19;
            break;
        case 14:
            pin = 20;
            break;
        case 15:
            pin = 21;
            break;
        case 16:
            pin = 22;
            break;
        case 17:
            pin = 23;
            break;
        case 18:
            pin = 14;
            break;
        case 19:
            pin = 16;
            break;
        case 20:
            pin = 15;
            break;
        default:
            pin = 13;
    }
    return pin;
}

@end

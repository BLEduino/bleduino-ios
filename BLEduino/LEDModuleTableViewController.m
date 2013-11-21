//
//  LEDModuleTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/12/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "LEDModuleTableViewController.h"
#import "LEDTableViewCell.h"

@implementation LEDModuleTableViewController
{
    //21 GPIO pins.
    
    //Digital pins.
    IBOutlet UITableViewCell *digital0Cell;
    IBOutlet UITableViewCell *digital1Cell;
    IBOutlet UITableViewCell *digital2Cell;
    IBOutlet UITableViewCell *digital3Cell;
    IBOutlet UITableViewCell *digital4Cell;
    IBOutlet UITableViewCell *digital5Cell;
    IBOutlet UITableViewCell *digital6Cell;
    IBOutlet UITableViewCell *digital7Cell;
    IBOutlet UITableViewCell *digital8Cell;
    IBOutlet UITableViewCell *digital9Cell;
    IBOutlet UITableViewCell *digital10Cell;
    IBOutlet UITableViewCell *digital13Cell;

    //Analog pins.
    IBOutlet UITableViewCell *analog0Cell;
    IBOutlet UITableViewCell *analog1Cell;
    IBOutlet UITableViewCell *analog2Cell;
    IBOutlet UITableViewCell *analog3Cell;
    IBOutlet UITableViewCell *analog4Cell;
    IBOutlet UITableViewCell *analog5Cell;
    
    //MISO, MOSI, SCK pins.
    IBOutlet UITableViewCell *misoCell;
    IBOutlet UITableViewCell *mosiCell;
    IBOutlet UITableViewCell *sckCell;
    
}

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
    
    /****************************************************************************/
    /*                              Digital Pins                                */
    /****************************************************************************/
    //Set Digital 0 pin.
    digital0Cell.textLabel.text = @"LED 1";
    digital0Cell.detailTextLabel.text = @"Pin 0";
    //Add switch and target for updates.
    UISwitch *ledSwitch0 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch0.tag = 100;
    [ledSwitch0 addTarget:self
                  action:@selector(ledSwitchToggled:)
        forControlEvents:UIControlEventTouchUpInside];
    [digital0Cell addSubview:ledSwitch0];
    
    //Set Digital 1 pin.
    digital1Cell.textLabel.text = @"LED 2";
    digital1Cell.detailTextLabel.text = @"Pin 1";
    //Add switch and target for updates.
    UISwitch *ledSwitch1 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch1.tag = 101;
    [ledSwitch1 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [digital1Cell addSubview:ledSwitch1];
    
    //Set Digital 2 pin.
    digital2Cell.textLabel.text = @"LED 3";
    digital2Cell.detailTextLabel.text = @"Pin 2";
    //Add switch and target for updates.
    UISwitch *ledSwitch2 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch2.tag = 102;
    [ledSwitch2 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [digital2Cell addSubview:ledSwitch2];
    
    //Set Digital 3 pin.
    digital3Cell.textLabel.text = @"LED 4";
    digital3Cell.detailTextLabel.text = @"Pin 3";
    //Add switch and target for updates.
    UISwitch *ledSwitch3 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch3.tag = 103;
    [ledSwitch3 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [digital3Cell addSubview:ledSwitch3];
    
    //Set Digital 4 pin.
    digital4Cell.textLabel.text = @"LED 5";
    digital4Cell.detailTextLabel.text = @"Pin 4";
    //Add switch and target for updates.
    UISwitch *ledSwitch4 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch4.tag = 104;
    [ledSwitch4 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [digital4Cell addSubview:ledSwitch4];
    
    //Set Digital 5 pin.
    digital5Cell.textLabel.text = @"LED 6";
    digital5Cell.detailTextLabel.text = @"Pin 5";
    //Add switch and target for updates.
    UISwitch *ledSwitch5 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch5.tag = 105;
    [ledSwitch5 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [digital5Cell addSubview:ledSwitch5];
    
    //Set Digital 6 pin.
    digital6Cell.textLabel.text = @"LED 7";
    digital6Cell.detailTextLabel.text = @"Pin 6";
    //Add switch and target for updates.
    UISwitch *ledSwitch6 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch6.tag = 106;
    [ledSwitch6 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [digital6Cell addSubview:ledSwitch6];
    
    //Set Digital 7 pin.
    digital7Cell.textLabel.text = @"LED 8";
    digital7Cell.detailTextLabel.text = @"Pin 7";
    //Add switch and target for updates.
    UISwitch *ledSwitch7 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch7.tag = 107;
    [ledSwitch7 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [digital7Cell addSubview:ledSwitch7];
    
    //Set Digital 8 pin.
    digital8Cell.textLabel.text = @"LED 9";
    digital8Cell.detailTextLabel.text = @"Pin 8";
    //Add switch and target for updates.
    UISwitch *ledSwitch8 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch8.tag = 108;
    [ledSwitch8 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [digital8Cell addSubview:ledSwitch8];
    
    //Set Digital 9 pin.
    digital9Cell.textLabel.text = @"LED 10";
    digital9Cell.detailTextLabel.text = @"Pin 9";
    //Add switch and target for updates.
    UISwitch *ledSwitch9 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch9.tag = 109;
    [ledSwitch9 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [digital9Cell addSubview:ledSwitch9];
    
    //Set Digital 10 pin.
    digital10Cell.textLabel.text = @"LED 11";
    digital10Cell.detailTextLabel.text = @"Pin 10";
    //Add switch and target for updates.
    UISwitch *ledSwitch10 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch10.tag = 110;
    [ledSwitch10 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [digital10Cell addSubview:ledSwitch10];
    
    //Set Digital 13 pin.
    digital13Cell.textLabel.text = @"LED 12";
    digital13Cell.detailTextLabel.text = @"Pin 13";
    //Add switch and target for updates.
    UISwitch *ledSwitch13 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitch13.tag = 111;
    [ledSwitch13 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [digital13Cell addSubview:ledSwitch13];
    

    /****************************************************************************/
    /*                              Analog Pins                                 */
    /****************************************************************************/
    //Set Analog 0 pin.
    analog0Cell.textLabel.text = @"LED 13";
    analog0Cell.detailTextLabel.text = @"Pin A0";
    //Add switch and target for updates.
    UISwitch *ledSwitchA0 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitchA0.tag = 112;
    [ledSwitchA0 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [analog0Cell addSubview:ledSwitchA0];
    
    //Set Analog 1 pin.
    analog1Cell.textLabel.text = @"LED 14";
    analog1Cell.detailTextLabel.text = @"Pin A1";
    //Add switch and target for updates.
    UISwitch *ledSwitchA1 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitchA1.tag = 113;
    [ledSwitchA1 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [analog1Cell addSubview:ledSwitchA1];
    
    //Set Analog 2 pin.
    analog2Cell.textLabel.text = @"LED 15";
    analog2Cell.detailTextLabel.text = @"Pin A2";
    //Add switch and target for updates.
    UISwitch *ledSwitchA2 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitchA2.tag = 114;
    [ledSwitchA2 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [analog2Cell addSubview:ledSwitchA2];
    
    //Set Analog 3 pin.
    analog3Cell.textLabel.text = @"LED 16";
    analog3Cell.detailTextLabel.text = @"Pin A3";
    //Add switch and target for updates.
    UISwitch *ledSwitchA3 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitchA3.tag = 115;
    [ledSwitchA3 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [analog3Cell addSubview:ledSwitchA3];
    
    //Set Analog 4 pin.
    analog4Cell.textLabel.text = @"LED 17";
    analog4Cell.detailTextLabel.text = @"Pin A4";
    //Add switch and target for updates.
    UISwitch *ledSwitchA4 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitchA4.tag = 116;
    [ledSwitchA4 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [analog4Cell addSubview:ledSwitchA4];
    
    //Set Analog 5 pin.
    analog5Cell.textLabel.text = @"LED 18";
    analog5Cell.detailTextLabel.text = @"Pin A5";
    //Add switch and target for updates.
    UISwitch *ledSwitchA5 = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitchA5.tag = 117;
    [ledSwitchA5 addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [analog5Cell addSubview:ledSwitchA5];
    
    
    /****************************************************************************/
    /*                          MISO, MOSI, SCK Pins                            */
    /****************************************************************************/
    //Set Digital 0 pin.
    misoCell.textLabel.text = @"LED 19";
    misoCell.detailTextLabel.text = @"Pin MISO";
    //Add switch and target for updates.
    UISwitch *ledSwitchMISO = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitchMISO.tag = 118;
    [ledSwitchMISO addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [misoCell addSubview:ledSwitchMISO];
    
    //Set Digital 0 pin.
    mosiCell.textLabel.text = @"LED 20";
    mosiCell.detailTextLabel.text = @"Pin MOSI";
    //Add switch and target for updates.
    UISwitch *ledSwitchMOSI = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitchMOSI.tag = 119;
    [ledSwitchMOSI addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [mosiCell addSubview:ledSwitchMOSI];
    
    //Set Digital 0 pin.
    sckCell.textLabel.text = @"LED 21";
    sckCell.detailTextLabel.text = @"Pin SCK";
    //Add switch and target for updates.
    UISwitch *ledSwitchSCK = [[UISwitch alloc] initWithFrame:CGRectMake(251, 8, 51, 31)];
    ledSwitchSCK.tag = 120;
    [ledSwitchSCK addTarget:self
                   action:@selector(ledSwitchToggled:)
         forControlEvents:UIControlEventTouchUpInside];
    [sckCell addSubview:ledSwitchSCK];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ledSwitchToggled:(id)sender
{
    UISwitch *ledSwitch = (UISwitch *)sender;

    //Create firmata command.
    FirmataCommandCharacteristic *ledToggleCommand = [[FirmataCommandCharacteristic alloc] init];
    ledToggleCommand.pinNumber = ledSwitch.tag - 100;
    ledToggleCommand.pinState = FirmataCommandPinStateOutput;
    ledToggleCommand.pinValue = [[NSNumber numberWithBool:ledSwitch.on] integerValue];
    
    //Send command.
    FirmataService *firmataService = [[FirmataService alloc] initWithPeripheral:Nil controller:self];
    [firmataService writeFirmataCommand:ledToggleCommand];
    
    NSLog(@"LED %d was turned %d", ledSwitch.tag - 99, [[NSNumber numberWithBool:ledSwitch.on] integerValue]);
}

@end

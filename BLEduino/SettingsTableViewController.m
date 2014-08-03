//
//  SettingsTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/24/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingsSwitchCell.h"
#import "SettingsNumberCell.h"
#import "RESideMenu.h"
#import "PowerRelayViewController.h"

#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*                                  Setup                                   */
/****************************************************************************/
@implementation SettingsTableViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Present admin (side) navigation menu.
- (IBAction)showMenu
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.sideMenuViewController presentMenuViewController];
}

//Show status bar after hiding the admin (side) nagivation menu.
- (void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark -
#pragma mark - Settings View Delegates
/****************************************************************************/
/*                          Settings Views Delegates                        */
/****************************************************************************/
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Update Power Relay settings.
    if(buttonIndex < 21)
    {
        if(actionSheet.tag == 100)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:buttonIndex forKey:SETTINGS_POWERRELAY_PIN_NUMBER];
            [defaults synchronize];
        }
        else if(actionSheet.tag == 101)
        {
            PowerSwitchStatusColor powerSwitchColor =
            (buttonIndex == 0)?PowerSwitchStatusColorBlue:PowerSwitchStatusColorGreenRed;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:powerSwitchColor forKey:SETTINGS_POWERRELAY_STATUS_COLOR];
            [defaults synchronize];
        }
        else if(actionSheet.tag == 102)
        {
            BOOL isDistanceFormatFeet = ![[NSNumber numberWithLong:buttonIndex] boolValue];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:isDistanceFormatFeet forKey:SETTINGS_PROXIMITY_DISTANCE_FORMAT_FT];
            [defaults synchronize];
        }
        
        //Update the data.
        [self.tableView reloadData];
    }
}

- (void)settingsSwitchToggled:(id)sender
{
    UISwitch *settingsSwitch = (UISwitch *)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Update Scanning/Connection settings.
    switch (settingsSwitch.tag) {
        //Scan only BLEduinos
        case 100:
            [defaults setBool:settingsSwitch.on forKey:SETTINGS_SCAN_ONLY_BLEDUINO];
            break;
            
        //Notify on Connect
        case 200:
            [defaults setBool:settingsSwitch.on forKey:SETTINGS_NOTIFY_CONNECT];
         break;

        //Notify on disconnect
        case 201:
            [defaults setBool:settingsSwitch.on forKey:SETTINGS_NOTIFY_DISCONNECT];
        break;
    }
    
    [defaults synchronize];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Update LCD settings.
    if(buttonIndex == 1) //Done button.
    {
        NSInteger lcdSize = [[alertView textFieldAtIndex:0].text integerValue];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:lcdSize forKey:SETTINGS_LCD_TOTAL_CHARS];
        [defaults synchronize];
        
        //Update the data.
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark TableView Delegate & DataSource
/****************************************************************************/
/*                  TableView Delegate & DataSource                         */
/****************************************************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //DEVICE SCAN SETTINGS
    if(indexPath.section == 0)
    {
        SettingsSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsSwitchCell"
                                                                   forIndexPath:indexPath];

        //Configure cell
        cell.settingDescription.text = @"Only BLEduinos";
        
        //Configure switch
        cell.settingsStatus.tag = 100;
        cell.settingsStatus.on = [prefs integerForKey:SETTINGS_SCAN_ONLY_BLEDUINO];
        [cell.settingsStatus addTarget:self
                                action:@selector(settingsSwitchToggled:)
                      forControlEvents:UIControlEventTouchUpInside];
        
        return  cell;
    }
    
    //DEVICE CONNECTION SETTINGS
    else if(indexPath.section == 1)
    {
        SettingsSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsSwitchCell"
                                                                   forIndexPath:indexPath];
       
        if(indexPath.row == 0)
        {
            //Configure cell
            cell.settingDescription.text = @"Notify on Connect";

            //Configure switch
            cell.settingsStatus.tag = 200;
            cell.settingsStatus.on = [prefs integerForKey:SETTINGS_NOTIFY_CONNECT];
            [cell.settingsStatus addTarget:self
                                    action:@selector(settingsSwitchToggled:)
                          forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            //Configure cell
            cell.settingDescription.text = @"Notify on Disconnect";

            //Configure switch
            cell.settingsStatus.tag = 201;
            cell.settingsStatus.on = [prefs integerForKey:SETTINGS_NOTIFY_DISCONNECT];
            [cell.settingsStatus addTarget:self
                                    action:@selector(settingsSwitchToggled:)
                          forControlEvents:UIControlEventTouchUpInside];
        }
        
        return  cell;
    }
    
    //MODULES SETTINGS
    else
    {
        SettingsNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsNumberCell"
                                                                   forIndexPath:indexPath];

        if(indexPath.row == 0)
        {
            //Configure cell
            cell.settingDescription.text = @"LCD Total Available Characters";
            NSInteger value = [prefs integerForKey:SETTINGS_LCD_TOTAL_CHARS];
            cell.settingsNumber.text = [NSString stringWithFormat:@"%ld", (long)value];

        }
        else if(indexPath.row == 1)
        {
            cell.settingDescription.text = @"Power Relay Pin";
            NSInteger value = [prefs integerForKey:SETTINGS_POWERRELAY_PIN_NUMBER];
            cell.settingsNumber.text = [SettingsTableViewController firmataPinNames:value];
        }
        else if(indexPath.row == 2)
        {
            cell.settingDescription.text = @"Power Relay Status Color";
            NSInteger statusColorValue = [prefs integerForKey:SETTINGS_POWERRELAY_STATUS_COLOR];
            NSString *colorString = (statusColorValue == PowerSwitchStatusColorGreenRed)?@"Green/Red":@"Blue";
            cell.settingsNumber.text = colorString;
        }
        else
        {
            cell.settingDescription.text = @"Proximity Distance Format";
            BOOL isDistanceFormatFeet = [prefs boolForKey:SETTINGS_PROXIMITY_DISTANCE_FORMAT_FT];
            NSString *distanceFormatString = (isDistanceFormatFeet)?@"ft":@"m";
            cell.settingsNumber.text = distanceFormatString;
        }
        return  cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell Index: s%li r%li", (long)indexPath.section, (long)indexPath.row);
    
    //LCD screen size.
    if(indexPath.section == 2 && indexPath.row == 0)
    {
        UIAlertView *lcdSize = [[UIAlertView alloc] initWithTitle:@"LCD Size"
                                                            message:@"Please enter the total available characters."
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Done", nil];
    
        lcdSize.alertViewStyle = UIAlertViewStylePlainTextInput;
        [lcdSize textFieldAtIndex:0].delegate = self;
        [lcdSize show];
    }
    
    //PowerRelay pin number.
    else if(indexPath.section == 2 && indexPath.row == 1)
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
       
        actionSheet.tag = 100;
        [actionSheet showInView:self.view];
    }
    
    //PowerRelay status color.
    else if(indexPath.section == 2 && indexPath.row == 2)
    {
        //Show color options.
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Select Color"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Blue", @"Green/Red", nil];
        
        actionSheet.tag = 101;
        [actionSheet showInView:self.view];
    }
    //PowerRelay status color.
    else if(indexPath.section == 2 && indexPath.row == 3)
    {
        //Show color options.
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Distance Format"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Feets", @"Meters", nil];
        
        actionSheet.tag = 102;
        [actionSheet showInView:self.view];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    
    switch (section) {
        case 0:
            rows = 1;
            break;
        case 1:
            rows = 2;
            break;
        case 2:
            rows = 4;
            break;
    }
    
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title;
    
    switch (section) {
        case 0:
            title = @"Only BLEduino devices will show up on the BLE Managaer.";
            break;
        case 1:
            title = @"Get notified whenever a BLEduino gets connected or disconnected.";
            break;
        case 2:
            title = @"Module specific settings.";
            break;
    }
    
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    
    switch (section) {
        case 0:
            title = @"Device Scan";
            break;
        case 1:
            title = @"Device Connection";
            break;
        case 2:
            title = @"Modules";
            break;
    }
    
    return title;
}

+ (NSString *) firmataPinNames:(NSInteger)pinNumber
{
    NSString *name;
    if(pinNumber < 12)
    {
        if(pinNumber == 11) pinNumber = pinNumber+2; //Fix for pin 13.
        name = [NSString stringWithFormat:@"%ld", (long)pinNumber];
    }
    else
    {
        switch (pinNumber) {
            case 12:
                name = @"A0";
                break;
            case 13:
                name = @"A1";
                break;
            case 14:
                name = @"A2";
                break;
            case 15:
                name = @"A3";
                break;
            case 16:
                name = @"A4";
                break;
            case 17:
                name = @"A5";
                break;
            case 18:
                name = @"MISO";
                break;
            case 19:
                name = @"MOSI";
                break;
            case 20:
                name = @"SCK";
                break;
                
        }
    }
    
    return name;
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
        //Push local notification.
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        //Is application on the foreground?
        if([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)
        {
            NSString *message = [NSString stringWithFormat:@"The BLE device '%@' has disconnected to the BLEduino app.", name];
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

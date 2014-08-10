//
//  ProximityViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/18/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "ProximityViewController.h"
#import "DistanceAlertController.h"
#import "RSSIAlertController.h"
#import "ProximityAlert.h"

@interface ProximityViewController ()

@end

@implementation ProximityViewController

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
    // Do any additional setup after loading the view.
    
    //Set appareance.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIColor *lightBlue = [UIColor colorWithRed:38/255.0 green:109/255.0 blue:235/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = lightBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    //Manager Delegate
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    leManager.delegate = self;
    
    //Set tableview delegate
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //Load alerts.
    [self setPreviousState];
    [self setAlertSwitch];
    
    //Receive distance notifications.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(distanceNotifications:) name:PROXIMITY_NEW_DISTANCE object:nil];
    [center addObserver:self selector:@selector(finishedDistanceCalibration:) name:PROXIMITY_FINISHED_CALIBRATION object:nil];
}

- (void)distanceNotifications:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"NewDistanceNotification"])
    {
        NSNumber *distance = (NSNumber *)[[notification userInfo] objectForKey:@"CurrentDistance"];
        [self updateDistanceIndicator:[distance integerValue]];
    }
}

- (void)setPreviousState
{
    //Load sequence.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *proximityMessages = (NSArray *)[defaults objectForKey:PROXIMITY_MESSAGES];
    NSArray *proximityDistances = (NSArray *)[defaults objectForKey:PROXIMITY_DISTANCES];
    NSArray *proximityDistancesTypes = (NSArray *)[defaults objectForKey:PROXIMITY_DISTANCES_TYPES];
    NSArray *proximityCloser = (NSArray *)[defaults objectForKey:PROXIMITY_CLOSER];
    NSArray *proximityFarther = (NSArray *)[defaults objectForKey:PROXIMITY_FARTHER];
    [defaults synchronize];

    self.alerts = [[NSMutableArray alloc] initWithCapacity:proximityMessages.count];
    
    for (int i=0; i<proximityMessages.count; i++)
    {
        ProximityAlert *alert = [[ProximityAlert alloc] init];
        alert.message = (NSString *)[proximityMessages objectAtIndex:i];
        alert.distance = [(NSNumber *)[proximityDistances objectAtIndex:i] integerValue];
        alert.isDistanceAlert = [(NSNumber *)[proximityDistancesTypes objectAtIndex:i] boolValue];
        alert.bleduinoIsCloser = [(NSNumber *)[proximityCloser objectAtIndex:i] boolValue];
        alert.bleduinoIsFarther = [(NSNumber *)[proximityFarther objectAtIndex:i] boolValue];
        
        [self.alerts addObject:alert];
    }
}

- (void)setAlertSwitch
{
    //Distance alerts enabled?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isAlertsEnabled = [defaults boolForKey:SETTINGS_PROXIMITY_DISTANCE_ALERT_ENABLED];
    [defaults synchronize];
    
    //Create header view.
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 227, 320, 44)];
    CGFloat borderWidth = 0.72f;
    headerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    headerView.layer.borderWidth = borderWidth;
    headerView.backgroundColor = [UIColor whiteColor];
    
    //Add subviews.
    UILabel *enableSwitchDescription = [[UILabel alloc] initWithFrame:CGRectMake(15, 11.5, 196, 21)];
    enableSwitchDescription.text = @"Show Distance Alerts";
    UISwitch *enableSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(251, 6, 51, 31)];
    [enableSwitch setOn:isAlertsEnabled animated:NO];
    [enableSwitch addTarget:self action:@selector(toggleGlobalDistanceAlertSwitch:)
           forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:enableSwitch];
    [headerView addSubview:enableSwitchDescription];
    
    //Set new header view.
    [self.view addSubview:headerView];
}

- (void)updateDistanceIndicator:(NSInteger)strengthLevel
{
    NSString *strengthName;
    switch (strengthLevel) {
        case 0:
            strengthName = @"strength-0.png";
            break;
        case 1:
            strengthName = @"strength-1.png";
            break;
        case 2:
            strengthName = @"strength-2.png";
            break;
        case 3:
            strengthName = @"strength-3.png";
            break;
        case 4:
            strengthName = @"strength-4.png";
            break;
        case 5:
            strengthName = @"strength-5.png";
            break;
        default:
            strengthName = @"strength-0.png";
            break;
    }
    
    //Update image.
    [UIView beginAnimations:@"Update Strength Image" context:nil];
    self.distanceIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:strengthName]];
    [UIView commitAnimations];
}

- (NSString *)stringForDistanceAlertDetailTextLabel:(ProximityAlert *)alert
{
    NSString *detailText;
    if(alert.isDistanceAlert)
    {
        switch (alert.distance) {
            case 0:
                detailText = @"Immediate";
                break;
            case 1:
                detailText = @"Near";
                break;
            case 2:
                detailText = @"Far";
                break;
            default:
                detailText = @"Error";
                break;
        }
    }
    else
    {
        detailText = [NSString stringWithFormat:@"%ld dBm", (long)alert.distance];
    }
    return detailText;
}

- (void)toggleGlobalDistanceAlertSwitch:(id)sender
{
    UISwitch *alertSwitch = (UISwitch *)sender;
    BOOL isAlertEnabled = alertSwitch.isOn;
    
    //Update global alerts enabled value.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isAlertEnabled forKey:SETTINGS_PROXIMITY_DISTANCE_ALERT_ENABLED];
    [defaults synchronize];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if(isAlertEnabled)
    {
        [center postNotificationName:PROXIMITY_DISTANCE_ALERTS_ENABLED object:self];
    }
    else
    {
        [center postNotificationName:PROXIMITY_DISTANCE_ALERTS_DISABLED object:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissModule:(id)sender
{
    [self storeDistanceAlerts];
    [self.delegate proximityControllerDismissed:self];
}

- (IBAction)addAlert:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Distance Alert", @"RSSI Alert", nil];


    //Show pin options.
    actionSheet.tag = (200 + 0);
    [actionSheet showInView:self.view];
}

- (IBAction)calibrate:(id)sender
{
    //First time calibrating distance?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isFirstCalibration = [defaults boolForKey:PROXIMITY_FIRST_CALIBRATION];
    
    if(isFirstCalibration)
    {
        [defaults setBool:NO forKey:PROXIMITY_FIRST_CALIBRATION];
        [defaults synchronize];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Calibration Explanation"
                                                        message:@"The distance displayed here is determined by the residual strength of the radio signal sent from the BLEduino after it has travel through the air. Radio signals are suceptible to everything they have to go through (e.g. walls, doors, air, humidity). Thus, calibration is done to have a konwn measurement at a given distance, and environment. Because radio signals are suceptible to so many things the distance provided here is only an estimation, and you should consider calibrating every time the testing environment changes."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Ok", nil];
        alert.tag = 75;
        [alert show];
    }
    else
    {        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Distance Calibration"
                                                        message:@"Please stand 1 meter (3.3 ft) away from the BLEduino, and make sure the path between the BLEduino and the iOS device is clear. Try not to move while calibration is being completed."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Start", nil];
        [alert show];
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != actionSheet.cancelButtonIndex)
    {
        if(buttonIndex)
        {
            //RSSI Alert
            [self performSegueWithIdentifier:@"RSSIAlertSegue" sender:self];
        }
        else
        {
            //Distance Alert
            [self performSegueWithIdentifier:@"DistanceAlertSegue" sender:self];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 75)//Calibration explanation.
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Distance Calibration"
                                                        message:@"Please stand 1 meter (3.3 ft) away from the BLEduino, and make sure the path between the BLEduino and the iOS device is clear. Try not to move while calibration is being completed."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Start", nil];
        [alert show];
    }
    else//Calibration process.
    {
        if(buttonIndex == 1)
        {
            [self sendBeginDistanceCalibrationNotification];
        }
    }
}

- (void)sendBeginDistanceCalibrationNotification
{
    //Show calibration indicator.
    [self.distanceIndicator setHidden:YES];
    [self.calibrationIndicator setHidden:NO];
    [self.calibrationIndicator startAnimating];
    [self.calibrationLabel setHidden:NO];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:PROXIMITY_BEGIN_CALIBRATION object:self];
}

- (void)finishedDistanceCalibration:(NSNotification *)notification
{
    //Show distance indicator.
    [self.distanceIndicator setHidden:NO];
    [self.calibrationIndicator stopAnimating];
    [self.calibrationLabel setHidden:YES];
}

- (void)storeDistanceAlerts
{
    //Store alerts for persistance.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *proximityMessages = [[NSMutableArray alloc] initWithCapacity:self.alerts.count];
    NSMutableArray *proximityDistances = [[NSMutableArray alloc] initWithCapacity:self.alerts.count];
    NSMutableArray *proximityTypes = [[NSMutableArray alloc] initWithCapacity:self.alerts.count];
    NSMutableArray *proximityCloser = [[NSMutableArray alloc] initWithCapacity:self.alerts.count];
    NSMutableArray *proximityFarther = [[NSMutableArray alloc] initWithCapacity:self.alerts.count];
    
    for (ProximityAlert *alert in self.alerts)
    {
        [proximityMessages  addObject:alert.message];
        [proximityDistances addObject:[NSNumber numberWithInteger:alert.distance]];
        [proximityTypes     addObject:[NSNumber numberWithBool:alert.isDistanceAlert]];
        [proximityCloser    addObject:[NSNumber numberWithBool:alert.bleduinoIsCloser]];
        [proximityFarther   addObject:[NSNumber numberWithBool:alert.bleduinoIsFarther]];
    }
    
    //Archive everything.
    [defaults setObject:proximityMessages   forKey:PROXIMITY_MESSAGES];
    [defaults setObject:proximityDistances  forKey:PROXIMITY_DISTANCES];
    [defaults setObject:proximityTypes      forKey:PROXIMITY_DISTANCES_TYPES];
    [defaults setObject:proximityCloser     forKey:PROXIMITY_CLOSER];
    [defaults setObject:proximityFarther    forKey:PROXIMITY_FARTHER];
    [defaults synchronize];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:PROXIMITY_NEW_DISTANCE_ALERTS object:self];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.alerts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProximityAlert *alert = [self.alerts objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProximityAlertCell"
                                                            forIndexPath:indexPath];
    
    cell.textLabel.text = alert.message;
    cell.detailTextLabel.text = [self stringForDistanceAlertDetailTextLabel:alert];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"EditDistanceAlertSegue"])
    {
        //Find alert.
        NSInteger index = ((NSIndexPath *)[self.tableView indexPathForSelectedRow]).row;
        self.indexOfLastAlertUpdated = index;
        
        UINavigationController *navigationController = segue.destinationViewController;
        DistanceAlertController *alertController = [[navigationController viewControllers] objectAtIndex:0];
        alertController.delegate = self;
        alertController.alert = [self.alerts objectAtIndex:index];
        alertController.isNewAlert = NO;
    }
    else if([segue.identifier isEqualToString:@"EditRSSIAlertSegue"])
    {
        //Find alert.
        NSInteger index = ((NSIndexPath *)[self.tableView indexPathForSelectedRow]).row;
        self.indexOfLastAlertUpdated = index;
        
        UINavigationController *navigationController = segue.destinationViewController;
        RSSIAlertController *alertController = [[navigationController viewControllers] objectAtIndex:0];
        alertController.delegate = self;
        alertController.alert = [self.alerts objectAtIndex:index];
        alertController.isNewAlert = NO;
    }
    else if([segue.identifier isEqualToString:@"DistanceAlertSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        DistanceAlertController *alertController = [[navigationController viewControllers] objectAtIndex:0];
        alertController.delegate = self;
        alertController.isNewAlert = YES;
    }
    else if([segue.identifier isEqualToString:@"RSSIAlertSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        RSSIAlertController *alertController = [[navigationController viewControllers] objectAtIndex:0];
        alertController.delegate = self;
        alertController.isNewAlert = YES;
    }
}

//Removing alerts
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.alerts removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProximityAlert *alert = [self.alerts objectAtIndex:indexPath.row];
    if(alert.isDistanceAlert)
    {
        [self performSegueWithIdentifier:@"EditDistanceAlertSegue" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"EditRSSIAlertSegue" sender:self];
    }
}

//Alert Delegates
- (void)distanceAlertControllerDismissed:(DistanceAlertController *)controller
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.indexOfLastAlertUpdated inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didUpdateDistanceAlert:(ProximityAlert *)alert fromController:(DistanceAlertController *)controller
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.indexOfLastAlertUpdated inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    ProximityAlert *distanceAlert = [self.alerts objectAtIndex:self.indexOfLastAlertUpdated];
    distanceAlert = alert;
    [self storeDistanceAlerts];
    
    [self.tableView reloadData];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCreateDistanceAlert:(ProximityAlert *)alert fromController:(DistanceAlertController *)controller
{
    [self.alerts addObject:alert];
    [self storeDistanceAlerts];
    
    [self.tableView reloadData];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)rssiAlertControllerDismissed:(RSSIAlertController *)controller
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.indexOfLastAlertUpdated inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didUpdateRSSIAlert:(ProximityAlert *)alert fromController:(RSSIAlertController *)controller
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.indexOfLastAlertUpdated inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    ProximityAlert *distanceAlert = [self.alerts objectAtIndex:self.indexOfLastAlertUpdated];
    distanceAlert = alert;
    [self storeDistanceAlerts];
    
    [self.tableView reloadData];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCreateRSSIAlert:(ProximityAlert *)alert fromController:(RSSIAlertController *)controller
{
    [self.alerts addObject:alert];
    [self storeDistanceAlerts];
    
    [self.tableView reloadData];
    [controller dismissViewControllerAnimated:YES completion:nil];
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

//
//  ModulesCollectionViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "AppDelegate.h"
#import "ModulesCollectionViewController.h"
#import "ModuleCollectionViewCell.h"
#import "RESideMenu.h"
#import "ProximityAlert.h"
#import "BDLeDiscoveryManager.h"
#import "ProximityViewController.h"

@implementation ModulesCollectionViewController

#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*                Module CollectionViewController Setup                     */
/****************************************************************************/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set services that run in the background.
    self.notificationService = [BDNotificationService sharedListener];
    self.bleBridge = [BDBleBridgeService sharedBridge];
    
    //Monitor distances from bleduino here (to be able to monitor in the background).
//    [self monitorBleduinoDistances];
    
    self.calibrationReadings = [[NSMutableArray alloc] initWithCapacity:20];
    self.currentReadings = [[NSMutableArray alloc] initWithCapacity:20];
    
    //Set appareance.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    UIColor *lightBlue = [UIColor colorWithRed:38/255.0 green:109/255.0 blue:235/255.0 alpha:1.0];
//    UIColor *lightBlue = [UIColor colorWithRed:19/255.0 green:147/255.0 blue:191/255.0 alpha:1.0];

    UIColor *lightBlue = [UIColor colorWithRed:22/255.0 green:170/255.0 blue:221/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = lightBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    //Manager Delegate
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    leManager.delegate = self;
    
    //Set notifications to monitor Alerts Enabled control, and distance calibration.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(distanceAlertNotification:) name:PROXIMITY_DISTANCE_ALERTS_ENABLED object:nil];
    [center addObserver:self selector:@selector(distanceAlertNotification:) name:PROXIMITY_DISTANCE_ALERTS_DISABLED object:nil];
    [center addObserver:self selector:@selector(distanceAlertNotification:) name:PROXIMITY_NEW_DISTANCE_ALERTS object:nil];
    [center addObserver:self selector:@selector(beginDistanceCalibration:)  name:PROXIMITY_BEGIN_CALIBRATION object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Proximity Module Logic
/****************************************************************************/
/*                          Proximity Module Logic                          */
/****************************************************************************/
// Proximity module logic is located here to be able to monitor distances
// and alerts on the background.

- (void)loadDistanceAlerts
{
    //Load sequence.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *proximityMessages = (NSArray *)[defaults objectForKey:PROXIMITY_MESSAGES];
    NSArray *proximityDistances = (NSArray *)[defaults objectForKey:PROXIMITY_DISTANCES];
    NSArray *proximityCloser = (NSArray *)[defaults objectForKey:PROXIMITY_CLOSER];
    NSArray *proximityFarther = (NSArray *)[defaults objectForKey:PROXIMITY_FARTHER];
    [defaults synchronize];
    
    self.distanceAlerts = [[NSMutableArray alloc] initWithCapacity:proximityMessages.count];
    
    for (int i=0; i<proximityMessages.count; i++)
    {
        ProximityAlert *alert = [[ProximityAlert alloc] init];
        alert.message = (NSString *)[proximityMessages objectAtIndex:i];
        alert.distance = (NSInteger)[proximityDistances objectAtIndex:i];
        alert.bleduinoIsCloser = (BOOL)[proximityCloser objectAtIndex:i];
        alert.bleduinoIsFarther = (BOOL)[proximityFarther objectAtIndex:i];
        
        [self.distanceAlerts addObject:alert];
    }
}

- (void)monitorBleduinoDistances
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    BOOL isProximityControllerPresent = [appDelegate.window.rootViewController isKindOfClass:[ProximityViewController class]];
    
    self.distanceAlertsEnabled = YES; //FIXME: REMOVE LATER
    
    if(self.distanceAlertsEnabled || isProximityControllerPresent)
    {
        BDLeDiscoveryManager *manager = [BDLeDiscoveryManager sharedLeManager];
        CBPeripheral *bleduino = [manager.connectedBleduinos lastObject];
        bleduino.delegate = self;
        [bleduino readRSSI];
        
        [self performSelector:@selector(monitorBleduinoDistances) withObject:nil afterDelay:1];
        
        if(self.distanceAlertsEnabled)
        {
            [self verifyDistanceAlerts];
        }
    }
}

- (void)verifyDistanceAlerts
{
    NSInteger currentDistance = 0;
    
    //Set margin of error.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL distanceFormatIsFeet = [defaults boolForKey:SETTINGS_PROXIMITY_DISTANCE_FORMAT_FT];
    [defaults synchronize];
    NSInteger distanceOffset = (distanceFormatIsFeet)?6:2;
    
    //Check alerts.
    for(ProximityAlert *alert in self.distanceAlerts)
    {
        if(currentDistance >= (alert.distance - distanceOffset) && currentDistance <= (alert.distance + distanceOffset))
        {
            //FIXME: VALIDATE IF CLOSER/FARTHER.
            [self pushDistanceAlertLocalNotification:alert];
        }
    }
}

- (void)pushDistanceAlertLocalNotification:(ProximityAlert *)alert
{
    //Push local notification.
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = alert.message;
    notification.alertAction = nil;
    notification.userInfo = @{@"title"  : @"Distance Alert",
                              @"message": alert.message,
                              @"ProximityModule": @"ProximityModule"};
    
    //Present notification.
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)distanceAlertNotification:(NSNotification *)notification
{
    NSString *name = [notification name];
    if([name isEqualToString:@"DistanceAlertsEnabled"])
    {
        self.distanceAlertsEnabled = YES;
        [self monitorBleduinoDistances];
    }
    else if([name isEqualToString:@"DistanceAlertsDisabled"])
    {
        self.distanceAlertsEnabled = NO;
    }
    else //New distance alert, load alerts again.
    {
        [self loadDistanceAlerts];
    }
}

- (void)beginDistanceCalibration:(NSNotification *)notification
{
    self.isCalibrating = YES;
    [self performSelector:@selector(sendFinishedDistanceCalibrationNotification) withObject:nil afterDelay:10];
}

- (void)sendFinishedDistanceCalibrationNotification
{
    //Calibration is over.
    self.isCalibrating = NO;
    self.measuredPower = [self.calibrationReadings valueForKeyPath:@"@avg.self"];
    
    //FIXME: TESTING REMOVE LATER
    NSLog(@"Measured Power: %@\n", [self.measuredPower description]);
    NSLog(@"Max: %@\n", [[self.calibrationReadings valueForKeyPath:@"@max.self"] description]);
    NSLog(@"Min: %@\n", [[self.calibrationReadings valueForKeyPath:@"@min.self"] description]);
    NSLog(@"Count: %@\n\n", [[self.calibrationReadings valueForKeyPath:@"@count.self"] description]);
    
//    NSLog(@"Readings: %@", [self.calibrationReadings description]);
    
    [self.calibrationReadings removeAllObjects];
    
    
    //Notify proximity controller so the veiw can be updated back to displaying current distance.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:PROXIMITY_FINISHED_CALIBRATION object:self];
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSNumber *currentRSSI = peripheral.RSSI;
    BOOL isValidReading = [self validateReading:currentRSSI];
    
    if(isValidReading && currentRSSI != nil)
    {
        //Collect reading.
        [self.currentReadings addObject:currentRSSI];
        self.currentDistance = [self calculateCurrentDistance];
        
        //Is user calibrating rignt now?
        if(self.isCalibrating)[self.calibrationReadings addObject:currentRSSI];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        BOOL isProximityControllerPresent = [appDelegate.window.rootViewController isKindOfClass:[ProximityViewController class]];
        
        //Do we need to push current distance to proximity controller?
        if(isProximityControllerPresent)
        {
            NSDictionary *distanceInfo = @{@"CurrentDistance":[NSNumber numberWithLong:self.currentDistance]};
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:PROXIMITY_NEW_DISTANCE object:self userInfo:distanceInfo];
        }
    }
}

- (BOOL) validateReading:(NSNumber *)rssi
{
    //FIXME: Validate RSSI i.e. no spikes, not larger than 127dBm
    return YES;
}

- (NSInteger) calculateCurrentDistance
{
    //FIXME: how to aggregate? determine how many packages, when to get rid of other packages
    //FIXME: calculate current RSSI (from aggregated);
    //FIXME: Convert RSSI to distance with Formula
    return 900;
}

#pragma mark -
#pragma mark - Collection View Data Source
/****************************************************************************/
/*                        UICollectionview Data Source                      */
/****************************************************************************/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    
    switch (indexPath.row) {
        case 0:
            //LCD Module
            cellIdentifier = @"LCDModuleCell";
            break;
        case 1:
            //Keyboard Module
            cellIdentifier = @"KeyboardModuleCell";
            break;
        case 2:
            //Game Controller Module
            cellIdentifier = @"GameControllerModuleCell";
            break;
        case 3:
            //Radio Controlled Module
            cellIdentifier = @"RadioControlledModuleCell";
            break;
        case 4:
            //Power Relay Module
            cellIdentifier = @"PowerRelayModuleCell";
            break;
        case 5:
            //LED Module
            cellIdentifier = @"LEDModuleCell";
            break;
        case 6:
            //Firmata Module
            cellIdentifier = @"FirmataModuleCell";
            break;
        case 7:
            //Sequencer Module
            cellIdentifier = @"SequencerModuleCell";
            break;
        case 8:
            //Proximity Module
            cellIdentifier = @"ProximityModuleCell";
            break;
        case 9:
            //Console Module
            cellIdentifier = @"ConsoleModuleCell";
            break;
        case 10:
            //Notifications Module
            cellIdentifier = @"NotificationsModuleCell";
            break;
        case 11:
            //BleBridge Module
            cellIdentifier = @"BleBridgeModuleCell";
            break;
    }
    
    ModuleCollectionViewCell *moduleCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                              forIndexPath:indexPath];
    
    //Set images for notifications and ble-bridge.
    if([cellIdentifier isEqualToString:@"NotificationsModuleCell"])
    {
        NSString *imageName = (self.notificationService.isListening)?@"notifications-s.png":@"notifications.png";
        [moduleCell.moduleIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    else if ([cellIdentifier isEqualToString:@"BleBridgeModuleCell"])
    {
        NSString *imageName = (self.notificationService.isListening)?@"bridge-s.png":@"bridge.png";
        [moduleCell.moduleIcon setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    
    return moduleCell;
}

#pragma mark -
#pragma mark - Collection View Delegate
/****************************************************************************/
/*                        UICollectionview Delegate                         */
/****************************************************************************/

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger module = indexPath.item;
    
    switch (module) {
        case 0:
            [self performSegueWithIdentifier:@"LCDModuleSegue" sender:self];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"GameControllerModuleSegue" sender:self];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"RadioControlledModuleSegue" sender:self];
            break;
            
        case 4:
            [self performSegueWithIdentifier:@"PowerRelayModuleSegue" sender:self];
            break;
            
        case 5:
            [self performSegueWithIdentifier:@"LEDModuleSegue" sender:self];
            break;
            
        case 6:
            [self performSegueWithIdentifier:@"FirmataModuleSegue" sender:self];
            break;
            
        case 7:
            [self performSegueWithIdentifier:@"SequencerModuleSegue" sender:self];
            break;
            
        case 8:
            [self performSegueWithIdentifier:@"ProximityModuleSegue" sender:self];
            break;
            
        case 9:
            [self performSegueWithIdentifier:@"ConsoleModuleSegue" sender:self];
            break;
            
        case 10:
            //Toggle notification service.
            if(self.notificationService.isListening)
            {
                [self.notificationService stopListeningWithDelegate:self];
                
                //Update icon.
                ModuleCollectionViewCell *cell = (ModuleCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell.moduleIcon setImage:[UIImage imageNamed:@"notifications.png"] forState:UIControlStateNormal];
            }
            else
            {
                [self presentSetupViewWithMessage:@"Starting listener..."];
                [self.notificationService startListeningWithDelegate:self];
                
                //Update icon.
                ModuleCollectionViewCell *cell = (ModuleCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell.moduleIcon setImage:[UIImage imageNamed:@"notifications-s.png"] forState:UIControlStateNormal];
            }
            break;
            
        case 11:
            //Toggle BLE bridge service.
            if(self.bleBridge.isOpen)
            {
                [self.bleBridge closeBridgeForDelegate:self];
                
                //Update icon.
                ModuleCollectionViewCell *cell = (ModuleCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell.moduleIcon setImage:[UIImage imageNamed:@"bridge.png"] forState:UIControlStateNormal];
            }
            else
            {
                [self presentSetupViewWithMessage:@"Opening BLE bridge..."];
                [self.bleBridge openBridgeForDelegate:self];
                
                //Update icon.
                ModuleCollectionViewCell *cell = (ModuleCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell.moduleIcon setImage:[UIImage imageNamed:@"bridge-s.png"] forState:UIControlStateNormal];
            }
            break;

    }
}

#pragma mark -
#pragma mark - Setup views for Notifications/BLE-Bridge.
/****************************************************************************/
/*               Setup Views for Notifications/BLE-Bridge                   */
/****************************************************************************/
- (void)presentSetupViewWithMessage:(NSString *)message
{
    UIColor *textColor = [UIColor darkGrayColor];
    UIColor *backgroundColor = [UIColor whiteColor];
    
    //Main view
    UIView *interrogationView = [[UIView alloc] initWithFrame:CGRectMake(60, 150, 200, 100)];
    interrogationView.backgroundColor = backgroundColor;
    
    //Indicator
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]
                                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.color = textColor;
    activity.frame = CGRectMake(80, 25, 35, 35);
    [activity startAnimating];
    
    //Label
    UILabel *indicatorText = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 200, 20)];
    [indicatorText setTextAlignment:NSTextAlignmentCenter];
    [indicatorText setFont:[UIFont systemFontOfSize:15]];
    [indicatorText setTextColor:textColor];
    indicatorText.text = message;
    
    //Interrogation View Background
    UIView *theView = [self.collectionView superview];
    
    CGRect tableViewFrame = CGRectMake(0, 0,
                                       theView.frame.size.width,
                                       theView.frame.size.height);
    UIView *interrogationBackgroundView = [[UIView alloc] initWithFrame:tableViewFrame];
    interrogationBackgroundView.backgroundColor = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:0.8];
    interrogationBackgroundView.tag = 1320;
    
    //Complete view
    [interrogationView addSubview:activity];
    [interrogationView addSubview:indicatorText];
    [interrogationBackgroundView addSubview:interrogationView];
    [theView addSubview:interrogationBackgroundView];
    
}

- (void)removeSetupView
{
    UIView *theView = [self.collectionView superview];
    [[theView viewWithTag:1320] removeFromSuperview];
}


#pragma mark -
#pragma mark - Collection Cell Details - Flow Layout Delegate
/****************************************************************************/
/*                          Flow Layour Delegate                            */
/****************************************************************************/

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(120, 120);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(0, 25, 0, 25);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(10, -15);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(10, 10);
}

#pragma mark -
#pragma mark - Modules Segues
/****************************************************************************/
/*                              Modules Segues                              */
/****************************************************************************/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"LCDModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        LCDTableViewController *lcdController = [[navigationController viewControllers] objectAtIndex:0];
        lcdController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"KeyboardModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        KeyboardModuleTableViewController *keyboardController = [[navigationController viewControllers] objectAtIndex:0];
        keyboardController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"GameControllerModuleSegue"])
    {
        GameControllerViewController *gameController = segue.destinationViewController;
        gameController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"RadioControlledModuleSegue"])
    {
        RadioControlledViewController *rcController = segue.destinationViewController;
        rcController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"PowerRelayModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        PowerRelayViewController *powerRelayController = [[navigationController viewControllers] objectAtIndex:0];
        powerRelayController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"LEDModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        LEDModuleTableViewController *ledController = [[navigationController viewControllers] objectAtIndex:0];
        ledController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"FirmataModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        FirmataTableViewController *firmataController = [[navigationController viewControllers] objectAtIndex:0];
        firmataController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"SequencerModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        SequencerTableViewController *sequencerController = [[navigationController viewControllers] objectAtIndex:0];
        sequencerController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"SequencerModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        SequencerTableViewController *sequencerController = [[navigationController viewControllers] objectAtIndex:0];
        sequencerController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"ProximityModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        ProximityViewController *proximityController = [[navigationController viewControllers] objectAtIndex:0];
        proximityController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"ConsoleModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        ConsoleTableViewController *consoleController = [[navigationController viewControllers] objectAtIndex:0];
        consoleController.delegate = self;
    }
}

#pragma mark -
#pragma mark - Modules Dismiss Delegates
/****************************************************************************/
/*                         Modules Dismiss' Delegate                        */
/****************************************************************************/
- (void)sequencerTableViewControllerDismissed:(SequencerTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)firmataTableViewControllerDismissed:(FirmataTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)lcdModuleTableViewControllerDismissed:(LCDTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)keyboardModuleTableViewControllerDismissed:(KeyboardModuleTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)gameControllerModuleViewControllerDismissed:(GameControllerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }];
}

- (void)radioControlledModuleViewControllerDismissed:(RadioControlledViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }];
}

- (void)powerRelayModulViewControllerDismissed:(PowerRelayViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)ledModuleTableViewControllerDismissed:(LEDModuleTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)proximityControllerDismissed:(ProximityViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)consoleControllerDismissed:(ConsoleTableViewController *)controller
{
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

#pragma mark -
#pragma mark - BLE Bridge Delegate
/****************************************************************************/
/*                           BLE-Bridge Delegate                            */
/****************************************************************************/
- (void)didFailToOpenBridge:(BDBleBridgeService *)service
{
    //Remove setup view.
    [self removeSetupView];
    
    //Something went wrong, close the bridge.
    [self.bleBridge closeBridgeForDelegate:self];
    
    //Present notification.
    NSString *message = @"The BLEduino app was unable to open a ble-bridge.";
    
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
                                  @"BleBridge": @"BleBridge"};
    }
    
    //Present notification.
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    //Update image.
    [self.collectionView reloadData];
}

- (void)didOpenBridge:(BDBleBridgeService *)service
{
    NSLog(@"BLE-Bridge opened succesfully.");
    //Remove setup view.
    [self performSelector:@selector(removeSetupView) withObject:nil afterDelay:1.0];
}

#pragma mark -
#pragma mark - Notification Delegate
/****************************************************************************/
/*                           Notification Delegate                          */
/****************************************************************************/
- (void)didFailToStartListening:(BDNotificationService *)service
{
    //Remove setup view.
    [self removeSetupView];
    
    //Something went wrong, close the bridge.
    [self.notificationService stopListeningWithDelegate:self];
    
    //Present notification.
    NSString *message = @"The BLEduino app was unable to start listening for notifications.";
    
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
                                  @"Notification": @"Notification"};
    }
    
    //Present notification.
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    //Update image.
    [self.collectionView reloadData];
}

- (void)didStatedListening:(BDNotificationService *)service
{
    NSLog(@"Notification is listening.");
    //Remove setup view.
    [self performSelector:@selector(removeSetupView) withObject:nil afterDelay:1.0];
}


@end

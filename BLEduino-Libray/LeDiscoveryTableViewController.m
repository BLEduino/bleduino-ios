//
//  LeDiscoveryTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "LeDiscoveryTableViewController.h"
#import "BDLeDiscoveryManager.h"
#import "RESideMenu.h"
#import "BleduinoController.h"

@interface LeDiscoveryTableViewController ()

@end

@implementation LeDiscoveryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    //Setup LeDiscovery manager.
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    leManager.delegate = self;
    
    //Start scanning for BLE devices.
    [self scanForBleDevices:self];
    
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
    
    //Setup referesh control.
    NSString *refreshMesage = (leManager.scanOnlyForBLEduinos)?
    @"Scanning for BLEduinos":@"Scanning for BLE devices";
    self.refreshControl = [[UIRefreshControl alloc] init];
	self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:refreshMesage];
	[self.refreshControl addTarget:self
                            action:@selector(scanForBleDevices:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)didFailToAttemptScannigForBleduinos:(CBCentralManagerState)sharedManagerSate
{
    NSString *message = @"Turn On Bluetooth to allow the \"BLEduino\" app to scan and connect to BLEduino devices.";
    UIAlertView *bleNotificationAlert = [[UIAlertView alloc]initWithTitle:message
                                                                  message:nil
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:@"Ok", nil];
    
    [bleNotificationAlert show];
}

- (void)didFailToAttemptConnectionToBleduino:(CBCentralManagerState)sharedManagerSate
{
    NSString *message = @"Turn On Bluetooth to allow the \"BLEduino\" app to scan and connect to BLEduino devices.";
    UIAlertView *bleNotificationAlert = [[UIAlertView alloc]initWithTitle:message
                                                                  message:nil
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:@"Ok", nil];
    
    [bleNotificationAlert show];
}

- (void)scanForBleDevices:(id)sender
{
    //Show network activity indicator.
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    [leManager startScanning];
    
//    [self performSelector:@selector(stopScanForBleDevices:) withObject:self afterDelay:5];
    
    [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:3.5];
}

- (void)stopScanForBleDevices:(id)sender
{
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    [leManager stopScanning];
    
    [self.refreshControl endRefreshing];
    
    //Hide network activity indicator.
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Table View Data Source & Delegate
/****************************************************************************/
/*                 BLEduino Devices Connected/Found                         */
/****************************************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if(section == 0)
    {//Connected Peripherals
        BDLeDiscoveryManager *manager = [BDLeDiscoveryManager sharedLeManager];
        rows = manager.connectedBleduinos.count;
    }
    else
    {//Found Peripherals
        BDLeDiscoveryManager *manager = [BDLeDiscoveryManager sharedLeManager];
        rows = manager.foundBleduinos.count;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0)?@"Connected Devices":@"Found Devices";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BlePeripheralCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    
    //Connected Peripherals
    if(indexPath.section == 0)
    {
        CBPeripheral *connectedBleduino = [leManager.connectedBleduinos objectAtIndex:indexPath.row];
        cell.textLabel.text = (connectedBleduino.name)?connectedBleduino.name:@"BLE Peripheral";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //Found Peripherals
    else
    {
        CBPeripheral *foundBleduino = [leManager.foundBleduinos objectAtIndex:indexPath.row];
        cell.textLabel.text = (foundBleduino.name)?foundBleduino.name:@"BLE Peripheral";
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    
    //PENDING: Streatched goal. Add more context to found/connected devcies.
    //For example, a dummy cell that displays "O found devices".
    
    return cell;
}

/****************************************************************************/
/*                        Connect/Disconnect BLEduinos                      */
/****************************************************************************/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        //PENDING: Stretched goal. Add more context information to discovered devcies (e.g. RSSI).
        [self performSegueWithIdentifier:@"BleduinoSegue" sender:self];
        
    }
    else
    {
        [self presentBleduinoInterrogationView];
        BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
        [leManager connectBleduino:leManager.foundBleduinos[indexPath.row]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"BleduinoSegue"])
    {
        BDLeDiscoveryManager *manager = [BDLeDiscoveryManager sharedLeManager];
        NSInteger index = self.tableView.indexPathForSelectedRow.row;
        
        BleduinoController *controller = (BleduinoController *)segue.destinationViewController;
        controller.bleduino = [manager.connectedBleduinos objectAtIndex:index];
        controller.delegate = self;
    }
}

- (void)presentBleduinoInterrogationView
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
    indicatorText.text = @"Discovering Services";
    
    //Interrogation View Background
    UIView *theView = [self.tableView superview];
    
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

- (void)removeBleduinoInterrogationView
{
    UIView *theView = [self.tableView superview];
    [[theView viewWithTag:1320] removeFromSuperview];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section > 0)?NO:YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 0)
    {
        BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
        [leManager disconnectBleduino:leManager.connectedBleduinos[indexPath.row]];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Disconnect";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark -
#pragma mark - Bleduino Controller Delegate
/****************************************************************************/
/*                  Bleduino Controller Delegate                            */
/****************************************************************************/
- (void)didDismissBleduinoController:(BleduinoController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didUpateBleduino:(CBPeripheral *)bleduino controller:(BleduinoController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
    
}


#pragma mark -
#pragma mark - LeManager Delegate
/****************************************************************************/
/*                            LeManager Delegate                            */
/****************************************************************************/
- (void) didDiscoverBleduino:(CBPeripheral *)bleduino withRSSI:(NSNumber *)RSSI
{
    [self.tableView reloadData];
    
    NSString *name = ([bleduino.name isEqualToString:@""])?@"BLE Peripheral":bleduino.name;
    NSLog(@"Discovered peripheral: %@", name);
}

- (void) didDiscoverBleDevice:(CBPeripheral *)bleDevice withRSSI:(NSNumber *)RSSI
{
    [self.tableView reloadData];
    
    NSString *name = ([bleDevice.name isEqualToString:@""])?@"BLE Peripheral":bleDevice.name;
    NSLog(@"Discovered peripheral: %@", name);
}

//Connected to BLEduino and BLE devices.
- (void) didConnectToBleduino:(CBPeripheral *)bleduino
{
    //Remove Bleduino interrogation view.
    [self removeBleduinoInterrogationView];
    
    [self.tableView reloadData];
    
    NSString *name = ([bleduino.name isEqualToString:@""])?@"BLE Peripheral":bleduino.name;
    NSLog(@"Connected to peripheral: %@", name);

    //Verify if notify setting is enabled.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL notifyConnect = [prefs integerForKey:SETTINGS_NOTIFY_CONNECT];
    
    if(notifyConnect)
    {
        NSString *message = [NSString stringWithFormat:@"The BLE device '%@' has connected to the BLEduino app.", name];

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
                                      @"connect": @"connect"};
        }
        
        //Present notification.
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

//Disconnected from BLEduino and BLE devices.
- (void) didDisconnectFromBleduino:(CBPeripheral *)bleduino error:(NSError *)error
{
    //Remove Bleduino interrogation view.
    [self removeBleduinoInterrogationView];
    
    [self.tableView reloadData];
    
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
    
    [self scanForBleDevices:self];
}

- (void)didFailToConnectToBleduino:(CBPeripheral *)bleduino error:(NSError *)error
{
    //Remove Bleduino interrogation view.
    [self removeBleduinoInterrogationView];
    
    NSString *name = ([bleduino.name isEqualToString:@""])?@"BLE Peripheral":bleduino.name;
    NSLog(@"Faild to connect to peripheral: %@", name);
    

    NSString *message = [NSString stringWithFormat:@"The BLE device '%@' failed to connect to the BLEduino Max ## app.", name];
    
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

    
    [self scanForBleDevices:self];
}

- (void) didUpdateBleduinoName:(CBPeripheral *)bleduino
{
    [self.tableView reloadData];
}

@end

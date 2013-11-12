//
//  LeDiscoveryTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "LeDiscoveryTableViewController.h"
#import "LeDiscoveryManager.h"
#import "RESideMenu.h"

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
    [self.sideMenuViewController presentMenuViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setup LeDiscovery manager.
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    leManager.delegate = self;
    
    //Start scanning for BLE devices.
    [self scanForBleDevices:self];
    
    //Set appareance.
    UIColor *darkBlue = [UIColor colorWithRed:50/255.0 green:81/255.0 blue:147/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = darkBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
//    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
//    NSString *refreshMesage = (leManager.scanOnlyForBLEduinos)?@"Scanning for BLEduinos":@"Scanning for BLE devices";
//    self.refreshControl = [[UIRefreshControl alloc] init];
//	self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:refreshMesage];
//	[self.refreshControl addTarget:self action:@selector(scanForBleDevices:) forControlEvents:UIControlEventValueChanged];
}

- (void)scanForBleDevices:(id)sender
{
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    
    if(leManager.scanOnlyForBLEduinos)
    {
        [leManager startScanningForBleduinos];
    }
    else
    {
        //PENDING.
    }
    
    [self performSelector:@selector(stopScanForBleDevices:) withObject:self afterDelay:5];
}

- (void)stopScanForBleDevices:(id)sender
{
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    [leManager stopScanning];
    
    [self.refreshControl endRefreshing];
    
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
        LeDiscoveryManager *manager = [LeDiscoveryManager sharedLeManager];
        rows = manager.connectedBleduinos.count;
    }
    else
    {//Found Peripherals
        LeDiscoveryManager *manager = [LeDiscoveryManager sharedLeManager];
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
    
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    
    //Connected Peripherals
    if(indexPath.section == 0)
    {
        CBPeripheral *connectedBleduino = [leManager.connectedBleduinos objectAtIndex:indexPath.row];
        cell.textLabel.text = connectedBleduino.name;
    }
    //Found Peripherals
    else
    {
        CBPeripheral *foundBleduino = [leManager.foundBleduinos objectAtIndex:indexPath.row];
        cell.textLabel.text = foundBleduino.name;
    }
    
    return cell;
}

/****************************************************************************/
/*                        Connect/Disconnect BLEduinos                      */
/****************************************************************************/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        //PENDING.
    }

    else
    {
        LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
        [leManager connectBleduino:leManager.foundBleduinos[indexPath.row]];
    }
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
        LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
        [leManager disconnectBleduino:leManager.connectedBleduinos[indexPath.row]];
        
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
#pragma mark - LeManager Delegate
/****************************************************************************/
/*                            LeManager Delegate                            */
/****************************************************************************/

- (void) didDiscoverBleduino:(CBPeripheral *)bleduino withRSSI:(NSNumber *)RSSI
{
//    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:1];
//    NSArray *array = [NSArray arrayWithObject:indexpath];
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];

    [self.tableView reloadData];
    NSLog(@"Discovered peripheral: %@", bleduino.name);
}

//Connecting to BLEduino and BLE devices.
- (void) didConnectToBleduino:(CBPeripheral *)bleduino
{
    //PENDING: Handled by Apple with disconnect key. Verify. If not move row to top section.
    //ONLY HANDLED IN BACKGROUND APPARENTLY
    
//    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
//    NSArray *array = [NSArray arrayWithObject:indexpath];
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];

    [self.tableView reloadData];
    NSLog(@"Connected to peripheral: %@", bleduino.name);
}

//Disconnecting from BLEduino and BLE devices.
- (void) didDisconnectFromBleduino:(CBPeripheral *)bleduino error:(NSError *)error
{
    //PENDING: Handled by Apple with disconnect key. Verify. If not push local notification.
    //ONLY HANDLED IN BACKGROUND APPARENTLY
    
    [self.tableView reloadData];
    NSLog(@"Disconnected from peripheral: %@", bleduino.name);

}


/****************************************************************************/
/*                     Dismiss Connection Controller                        */
/****************************************************************************/
- (IBAction)dismissConnectionController:(id)sender
{
    [self.delegate leDiscoveryTableViewControllerDismissed:self];
}

@end

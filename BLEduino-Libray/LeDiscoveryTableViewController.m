//
//  LeDiscoveryTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "LeDiscoveryTableViewController.h"
#import "LeDiscoveryManager.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setup LeDiscovery manager.
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    leManager.delegate = self;
    
    NSString *refreshMesage = (leManager.scanOnlyForBLEduinos)?@"Scanning for BLEduinos":@"Scanning for BLE devices";
    self.refreshControl = [UIRefreshControl new];
	self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:refreshMesage];
	[self.refreshControl addTarget:self action:@selector(scanForBleDevices:) forControlEvents:UIControlEventValueChanged];
    
    //Start scanning for BLE devices.
    [leManager startScanningForBleduinos];
}

- (void) viewWillAppear:(BOOL)animated
{

}

- (void)scanForBleDevices:(id)sender
{
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    [leManager startScanningForBleduinos];
    
    [self performSelector:@selector(stopScanForBleDevices:) withObject:self afterDelay:15];
}

- (void)stopScanForBleDevices:(id)sender
{
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    [leManager stopScanning];
    
    [self.refreshControl endRefreshing];
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
        rows = self.connectedBleduinos.count;
    }
    else
    {//Found Peripherals
        rows = self.foundBleduinos.count;
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
    
    //Connected Peripherals
    if(indexPath.section == 0)
    {
        CBPeripheral *connectedBleduino = [self.connectedBleduinos objectAtIndex:indexPath.row];
        cell.textLabel.text = connectedBleduino.name;
    }
    //Found Peripherals
    else
    {
        CBPeripheral *foundBleduino = [self.foundBleduinos objectAtIndex:indexPath.row];
        cell.textLabel.text = foundBleduino.name;
    }
    
    return cell;
}

/****************************************************************************/
/*                        Connect/Disconnect BLEduinos                      */
/****************************************************************************/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    [leManager connectBleduino:self.foundBleduinos[indexPath.row]];
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
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -
#pragma mark - LeManager Delegate
/****************************************************************************/
/*                            LeManager Delegate                            */
/****************************************************************************/

- (void) didDiscoverBleduino:(CBPeripheral *)bleduino withRSSI:(NSNumber *)RSSI
{
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSArray *array = [NSArray arrayWithObject:indexpath];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
//    [self.tableView reloadData];
    
    NSLog(@"Discovered peripheral: %@", bleduino.name);
}

//Connecting to BLEduino and BLE devices.
- (void) didConnectToBleduino:(CBPeripheral *)bleduino
{
    //PENDING: Handled by Apple with disconnect key. Verify. If not move row to top section.
    //ONLY HANDLED IN BACKGROUND APPARENTLY
    
    [self.tableView reloadData];
    NSLog(@"Connected to peripheral: %@", bleduino.name);
}

//Disconnecting from BLEduino and BLE devices.
- (void) didDisconnectFromBleduino:(CBPeripheral *)bleduino error:(NSError *)error
{
    //PENDING: Handled by Apple with disconnect key. Verify. If not push local notification.
    //ONLY HANDLED IN BACKGROUND APPARENTLY
    [self.tableView reloadData];
}


/****************************************************************************/
/*                     Dismiss Connection Controller                        */
/****************************************************************************/
- (IBAction)dismissConnectionController:(id)sender
{
    [self.delegate leDiscoveryTableViewControllerDismissed:self];
}

@end

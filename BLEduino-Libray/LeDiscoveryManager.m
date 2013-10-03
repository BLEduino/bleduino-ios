//
//  ConnectionManager.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "LeDiscoveryManager.h"

@implementation LeDiscoveryManager
{
    CBCentralManager *centralManager;
}

static LeDiscoveryManager *sharedInstance = NULL;

#pragma mark -
#pragma mark Access to Central Manager
/****************************************************************************/
/*				        Accesing to Central Manager    				        */
/****************************************************************************/
-(id)init {
    if (self = [super init]) {
        
        NSDictionary *options = @{@"CBCentralManagerOptionShowPowerAlertKey" : @YES};
        dispatch_queue_t bleQueue = dispatch_queue_create("ble-central", DISPATCH_QUEUE_SERIAL);
		centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                              queue:bleQueue
                                                            options:options];
                          
        self.foundBleduinos = [[NSMutableArray alloc] init];
        self.connectedBleduinos = [[NSMutableArray alloc] init];
        self.connectedServices = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (LeDiscoveryManager *)sharedLeManager {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance=[[LeDiscoveryManager alloc] init];
    }
    return sharedInstance;
}

- (void)dismiss
{
    sharedInstance = nil; //Destroy central manager.
    
    //Destroy all stored devices and services.
    self.foundBleduinos = self.connectedBleduinos = self.connectedServices = nil;
    //PENDING: Add support to destroy persisted information.
}

#pragma mark -
#pragma mark Central Manager Actions
/****************************************************************************/
/*			Central Manager Actions: scan/connect/disconnect   		        */
/****************************************************************************/

- (void) startScanningForBleduinos
{
    self.scanOnlyForBLEduinos = YES;
    
    NSArray *services = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"180A"]];
    
    [centralManager scanForPeripheralsWithServices:services options:nil];
}

- (void) stopScanning
{
    [centralManager stopScan];
}

- (void) connectBleduino:(CBPeripheral *)bleduino
{

    NSDictionary *connectBleOptions =
    @{@"CBConnectPeripheralOptionNotifyOnConnectionKey" : (self.notifyConnect)?@YES:@NO,
      @"CBConnectPeripheralOptionNotifyOnDisconnectionKey" : (self.notifyDisconnect)?@YES:@NO};
    
    [centralManager connectPeripheral:bleduino options:connectBleOptions];
}


- (void) disconnectBleduino:(CBPeripheral *)bleduino
{
    [centralManager cancelPeripheralConnection:bleduino];
}


//Central Manager Delegate
#pragma mark -
#pragma mark CM - Connection Delegate
/****************************************************************************/
/*				Connecting/Disconecting to BLE peripheral    				*/
/****************************************************************************/
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    
}


#pragma mark -
#pragma mark CM - Discovery Delegate.
/****************************************************************************/
/*				         Discovering BLE peripherals    				    */
/****************************************************************************/
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    
}

#pragma mark -
#pragma mark CM - Peripheral Access Delegate.
/****************************************************************************/
/*				         Accesing BLE peripherals    			     	    */
/****************************************************************************/
- (void)centralManager:(CBCentralManager *)central
didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    
}

- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)peripherals
{
    
}

/****************************************************************************/
/*				         Central Manager Availability     				    */
/****************************************************************************/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"Central manager state was updated.");

}





@end

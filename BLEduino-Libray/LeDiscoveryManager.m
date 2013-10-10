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
                          
        self.foundBleduinos = [[NSMutableOrderedSet alloc] init];
        self.connectedBleduinos = [[NSMutableOrderedSet alloc] init];
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
    self.foundBleduinos = self.connectedBleduinos = nil;
    self.connectedServices = nil;
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
    
    NSString *uartNordic = @"6e400001-b5a3-f393-e0a9-e50e24dcca9e";
    uartNordic = [uartNordic uppercaseString];
    NSArray *services = @[[CBUUID UUIDWithString:uartNordic],[CBUUID UUIDWithString:@"180A"]];
    
    [centralManager scanForPeripheralsWithServices:services options:nil];
}

- (void) startScanningForBleduinosWithTimeout:(NSTimeInterval)timeout
{
    [self startScanningForBleduinos];
    
    [self performSelector:@selector(stopScanning) withObject:self afterDelay:timeout];
}


- (void) stopScanning
{
    [centralManager stopScan];
}

- (void)connectBleduino:(CBPeripheral *)bleduino
{
    NSDictionary *connectBleOptions =
    @{@"CBConnectPeripheralOptionNotifyOnConnectionKey" : (self.notifyConnect)?@YES:@NO,
      @"CBConnectPeripheralOptionNotifyOnDisconnectionKey" : (self.notifyDisconnect)?@YES:@NO};
    
    [centralManager connectPeripheral:bleduino options:connectBleOptions];
}


- (void) disconnectBleduino:(CBPeripheral *)bleduino
{
    NSLog(@"CACA");
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
    //Move peripheral to connected devices.
    [self.foundBleduinos removeObject:peripheral];
    [self.connectedBleduinos insertObject:peripheral atIndex:0];
    
    
    NSString *uartNordic = @"6e400001-b5a3-f393-e0a9-e50e24dcca9e";
    uartNordic = [uartNordic uppercaseString];
    CBUUID *uuidUartService = [CBUUID UUIDWithString:uartNordic];

    peripheral.delegate = self;
    [peripheral discoverServices:@[uuidUartService]];
    
    [self.delegate didConnectToBleduino:peripheral];
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    
    //Move peripheral to connected devices.
    [self.connectedBleduinos removeObject:peripheral];
    [self.foundBleduinos insertObject:peripheral atIndex:0];
    
    [self.delegate didDisconnectFromBleduino:peripheral error:error];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    [self.delegate didFailToConnectToBleduino:peripheral error:error];
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
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    if(leManager.scanOnlyForBLEduinos)
    {
        //PENDING: Confirm peripheral is BLEduino with `advertisementData`.
        if(@YES)
        {
            if(![self.foundBleduinos containsObject:peripheral] && ![self.connectedBleduinos containsObject:peripheral])
            {
                [self.foundBleduinos insertObject:peripheral atIndex:0];
                [self.delegate didDiscoverBleduino:peripheral withRSSI:RSSI];
            }
        }
    }
    else
    {
        if(![self.foundBleduinos containsObject:peripheral] && ![self.connectedBleduinos containsObject:peripheral])
        {
            [self.foundBleduinos insertObject:peripheral atIndex:0];
            [self.delegate didDiscoverBleDevice:peripheral withRSSI:RSSI];
        }
    }
}

#pragma mark -
#pragma mark CM - Peripheral Access Delegate.
/****************************************************************************/
/*				         Accesing BLE peripherals    			     	    */
/****************************************************************************/
- (void)centralManager:(CBCentralManager *)central
didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    //PENDING.
}

- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)peripherals
{
    //PENDING.
}

/****************************************************************************/
/*				         Central Manager Availability     				    */
/****************************************************************************/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //PENDING.
    NSLog(@"Central manager state was updated.");
}

/****************************************************************************/
/*				         Peripheral Delegate               				    */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    peripheral.delegate = self;
    NSString *uartNordic = @"6e400001-b5a3-f393-e0a9-e50e24dcca9e";
    CBUUID *uuidService = [CBUUID UUIDWithString:uartNordic];
    
    for(CBService *service in peripheral.services)
    {
        if([service.UUID isEqual:uuidService])
        {
            CBUUID *uuidRX = [CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"];
            [peripheral discoverCharacteristics:@[uuidRX] forService:service];
            NSLog(@"Found Service");
        }

    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    NSString *uartNordic = @"6e400001-b5a3-f393-e0a9-e50e24dcca9e";
    CBUUID *uuidService = [CBUUID UUIDWithString:uartNordic];
    
    CBUUID *uuidRX = [CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"];
    
    for(CBService *service in peripheral.services)
    {
        if([service.UUID isEqual:uuidService])
        {
            for(CBCharacteristic *bleChar in service.characteristics)
            {
                if([bleChar.UUID isEqual:uuidRX])
                {
                    self.uartRXChar = bleChar;
                    NSLog(@"Found Characteristic");
                }
            }
        }
    }
}


@end

//
//  ConnectionManager.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "LeDiscoveryManager.h"
#import "UARTService.h"
#import "VehicleMotionService.h"
#import "NotificationService.h"
#import "FirmataService.h"
#import "ControllerService.h"
#import "BleBridgeService.h"

@implementation LeDiscoveryManager
{
    CBCentralManager *_centralManager;
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
		_centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                              queue:bleQueue
                                                            options:options];
                          
        self.foundBleduinos = [[NSMutableOrderedSet alloc] init];
        self.connectedBleduinos = [[NSMutableOrderedSet alloc] init];
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
    
    [_centralManager scanForPeripheralsWithServices:services options:nil];
}

- (void) startScanningForBleduinosWithTimeout:(NSTimeInterval)timeout
{
    [self startScanningForBleduinos];
    
    [self performSelector:@selector(stopScanning) withObject:self afterDelay:timeout];
}


- (void) stopScanning
{
    [_centralManager stopScan];
}

- (void)connectBleduino:(CBPeripheral *)bleduino
{
    NSDictionary *connectBleOptions =
    @{@"CBConnectPeripheralOptionNotifyOnConnectionKey" : (self.notifyConnect)?@YES:@NO,
      @"CBConnectPeripheralOptionNotifyOnDisconnectionKey" : (self.notifyDisconnect)?@YES:@NO};
    
    [_centralManager connectPeripheral:bleduino options:connectBleOptions];
}


- (void) disconnectBleduino:(CBPeripheral *)bleduino
{
    [_centralManager cancelPeripheralConnection:bleduino];
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
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate didDiscoverBleduino:peripheral withRSSI:RSSI];
                });
            }
        }
    }
    else
    {
        if(![self.foundBleduinos containsObject:peripheral] && ![self.connectedBleduinos containsObject:peripheral])
        {
            [self.foundBleduinos insertObject:peripheral atIndex:0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didDiscoverBleDevice:peripheral withRSSI:RSSI];
            });
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
    
    for(CBService *service in peripheral.services)
    {
        //Service: UART
        if([service.UUID isEqual:[CBUUID UUIDWithString:kUARTServiceUUIDString]])
        {
            NSLog(@"Discovered UART service for peripheral: %@, UUID: %@", peripheral.name, peripheral.identifier.UUIDString);
            CBUUID *rxCharacteristicUUID = [CBUUID UUIDWithString:kRxCharacteristicUUIDString];
            CBUUID *txCharacteristicUUID = [CBUUID UUIDWithString:kTxCharacteristicUUIDString];

            //Discover Characteristics
            [peripheral discoverCharacteristics:@[rxCharacteristicUUID,txCharacteristicUUID]
                                     forService:service];
        }
        
        //Service: Vehicle Motion
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kVehicleMotionServiceUUIDString]])
        {
            NSLog(@"Discovered Vehicle Motion service for peripheral: %@, UUID: %@", peripheral.name, peripheral.identifier.UUIDString);
            CBUUID *throttleYawRollPitchCharacteristicUUID = [CBUUID UUIDWithString:kThrottleYawRollPitchCharacteristicUUIDString];
            
            //Discover Characteristics
            [peripheral discoverCharacteristics:@[throttleYawRollPitchCharacteristicUUID]
                                     forService:service];
        }
        
        //Service: Notification
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kNotificationServiceUUIDString]])
        {
            NSLog(@"Discovered Notification service for peripheral: %@, UUID: %@", peripheral.name, peripheral.identifier.UUIDString);
            CBUUID *notificationAttributesCharacteristicUUID = [CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString];
            
            //Discover Characteristics
            [peripheral discoverCharacteristics:@[notificationAttributesCharacteristicUUID]
                                     forService:service];
        }
        
        //Service: Firmata
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kFirmataServiceUUIDString]])
        {
            NSLog(@"Discovered Firmata service for peripheral: %@, UUID: %@", peripheral.name, peripheral.identifier.UUIDString);
            CBUUID *firmataCommandCharacteristicUUID = [CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString];
            
            //Discover Characteristics
            [peripheral discoverCharacteristics:@[firmataCommandCharacteristicUUID]
                                     forService:service];
        }
        
        //Service: BleBridge
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kBleBridgeServiceUUIDString]])
        {
            NSLog(@"Discovered BleBridge service for peripheral: %@, UUID: %@", peripheral.name, peripheral.identifier.UUIDString);
            CBUUID *bridgeRxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeRxCharacteristicUUIDString];
            CBUUID *bridgeTxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString];
            CBUUID *deviceIDCharacteristicUUID = [CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString];

            //Discover Characteristics
            [peripheral discoverCharacteristics:@[bridgeRxCharacteristicUUID,bridgeTxCharacteristicUUID, deviceIDCharacteristicUUID]
                                     forService:service];
        }
        
        //Service: Controller
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kControllerServiceUUIDString]])
        {
            NSLog(@"Discovered Controller service for peripheral: %@, UUID: %@", peripheral.name, peripheral.identifier.UUIDString);
            CBUUID *buttonActionCharacteristicUUID = [CBUUID UUIDWithString:kButtonActionCharacteristicUUIDString];
            
            //Discover Characteristics
            [peripheral discoverCharacteristics:@[buttonActionCharacteristicUUID]
                                     forService:service];
        }
        
        //Service: Unkown
        else
        {
            NSString* uuidString = CFBridgingRelease(CFUUIDCreateString(nil, (__bridge CFUUIDRef)(service.UUID)));
            NSLog(@"Discovered unknonw service. This service is not supported by the BLEduino iOS library. Service:%@", uuidString);
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    for(CBService *service in peripheral.services)
    {
        //Service: UART
        if([service.UUID isEqual:[CBUUID UUIDWithString:kUARTServiceUUIDString]])
        {
            NSLog(@"Discovered the following characteristics for UART srvice, for peripheral: %@, UUID: %@",
                  peripheral.name, peripheral.identifier.UUIDString);
            
            for(CBCharacteristic *characteristic in service.characteristics)
            {
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kRxCharacteristicUUIDString]])
                {
                    NSLog(@"Read (Rx) Characteristic");
                }
                else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kTxCharacteristicUUIDString]])
                {
                    NSLog(@"Write (Tx) Characteristic");
                }
            }
        }
        
        //Service: Vehicle Motion
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kVehicleMotionServiceUUIDString]])
        {
            NSLog(@"Discovered the following characteristics for Vehicle Motion srvice, for peripheral: %@, UUID: %@",
                  peripheral.name, peripheral.identifier.UUIDString);
            
            for(CBCharacteristic *characteristic in service.characteristics)
            {
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kThrottleYawRollPitchCharacteristicUUIDString]])
                {
                    NSLog(@"Throttle-Yaw-Roll-Pitch Characteristic");
                }
            }
        }
        
        //Service: Notification
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kNotificationServiceUUIDString]])
        {
            NSLog(@"Discovered the following characteristics for Notification srvice, for peripheral: %@", peripheral.identifier.UUIDString);
            for(CBCharacteristic *characteristic in service.characteristics)
            {
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString]])
                {
                    NSLog(@"Notification Attributes Characteristic");
                }
            }
        }
    
        //Service: Firmata
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kFirmataServiceUUIDString]])
        {
            NSLog(@"Discovered the following characteristics for Firmata srvice, for peripheral: %@, UUID: %@",
                  peripheral.name, peripheral.identifier.UUIDString);
            
            for(CBCharacteristic *characteristic in service.characteristics)
            {
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString]])
                {
                    NSLog(@"Firmata Command Characteristic");
                }
            }
        }
        
        //Service: BleBridge
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kBleBridgeServiceUUIDString]])
        {
            NSLog(@"Discovered the following characteristics for BleBridge srvice, for peripheral: %@, UUID: %@",
                  peripheral.name, peripheral.identifier.UUIDString);
            
            for(CBCharacteristic *characteristic in service.characteristics)
            {
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeRxCharacteristicUUIDString]])
                {
                    NSLog(@"Bridge Read (Rx) Characteristic");
                }
                else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString]])
                {
                    NSLog(@"Bridge Write (Tx) Characteristic");
                }
                else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString]])
                {
                    NSLog(@"DeviceID Characteristic");
                }
            }
        }
        
        //Service: Controller
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kControllerServiceUUIDString]])
        {
            NSLog(@"Discovered the following characteristics for Controller srvice, for peripheral: %@, UUID: %@",
                  peripheral.name, peripheral.identifier.UUIDString);
            
            for(CBCharacteristic *characteristic in service.characteristics)
            {
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kButtonActionCharacteristicUUIDString]])
                {
                    NSLog(@"Button Action Characteristic");
                }
            }
        }
    }
}


@end

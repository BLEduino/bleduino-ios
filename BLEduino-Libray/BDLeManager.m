//
//  ConnectionManager.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDLeManager.h"
#import "BDUart.h"
#import "BDVehicleMotion.h"
#import "BDNotification.h"
#import "BDFirmata.h"
#import "BDController.h"
#import "BDBleBridge.h"

@interface BDLeManager ()
@property CBCentralManager *centralManager;
@end

@implementation BDLeManager

#pragma mark -
#pragma mark Access to Central Manager
/****************************************************************************/
/*				        Accesing to Central Manager    				        */
/****************************************************************************/
-(id)init {
    if (self = [super init]) {
        
        NSDictionary *options = @{@"CBCentralManagerOptionShowPowerAlertKey" : @YES};
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
        
        //Peripheral storage.
        self.foundBleduinos = [[NSMutableOrderedSet alloc] init];
        self.connectedBleduinos = [[NSMutableOrderedSet alloc] init];
        
        //Ble commands storage.
        self.bleCommands = [BDQueue queue];
        
        //Create and launch queue for executing ble-commands.
        dispatch_queue_t bleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(bleQueue, ^{
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            double timeCap = [defaults doubleForKey:WRITE_TIME_CAP];
            [defaults synchronize];
                        
            BDLeManager *manager = [BDLeManager sharedLeManager];
            BDQueue *bleCommands = manager.bleCommands;

            while(1)
            {
                @try
                {
                    //Execute commands off the queue.
                    void (^command)(void) = [bleCommands dequeue]; //Get ble command.
                    if(command)command(); //Run ble command.
                    
                    //Sleep
                    [NSThread sleepForTimeInterval:timeCap/1000.0];
                }
                @catch (NSException *exception)
                {
                    NSLog(@"Caught something, %@", exception.reason);
                }
            }
        });
        
        //Set configuration.
        [self configureLeDiscoveryManager:YES];
    }
    return self;
}


+ (BDLeManager *)sharedLeManager
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
    });
    return sharedManager;
}

- (void)dismiss
{
    //Destroy all stored devices and services.
    self.foundBleduinos = self.connectedBleduinos = nil;
}

- (BOOL)getScanOnlyForBLEduinos
{
    _scanOnlyForBLEduinos = [[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_SCAN_ONLY_BLEDUINO];
    return _scanOnlyForBLEduinos;
}

- (BOOL)getNotifyConnect
{
    _notifyConnect = [[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_NOTIFY_CONNECT];
    return _notifyConnect;
}

- (BOOL)getNotifyDisconnect
{
    _notifyDisconnect = [[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_NOTIFY_DISCONNECT];
    return _notifyDisconnect;
}

#pragma mark -
#pragma mark Central Manager Actions
/****************************************************************************/
/*			Central Manager Actions: scan/connect/disconnect   		        */
/****************************************************************************/
- (void) startScanning
{
    if(self.scanOnlyForBLEduinos)
    {
        [self startScanningForBleduinos];
    }
    else
    {
        [self startScanningForBleDevices];
    }
}

- (void) startScanningForBleDevices
{
    if(self.centralManager.state == CBCentralManagerStatePoweredOn)
    {
        //Scan for BLEduino service.
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(didFailToAttemptScannigForBleduinos:)])
        {
            [self.delegate didFailToAttemptScannigForBleduinos:self.centralManager.state];
        }
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:BLE_MANAGER_NOT_POWERED_ON object:self];
    }
}

- (void) startScanningForBleduinos
{
    if(self.centralManager.state == CBCentralManagerStatePoweredOn)
    {
        //Scan for BLEduino service.
        [self.foundBleduinos removeAllObjects];

        NSArray *services = @[[CBUUID UUIDWithString:kBLEduinoServiceUUIDString]];
        [self.centralManager scanForPeripheralsWithServices:services options:nil];
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(didFailToAttemptScannigForBleduinos:)])
        {
            [self.delegate didFailToAttemptScannigForBleduinos:self.centralManager.state];
        }
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:BLE_MANAGER_NOT_POWERED_ON object:self];
    }
}

- (void) startScanningForBleduinosWithTimeout:(NSTimeInterval)timeout
{
    if(self.centralManager.state == CBCentralManagerStatePoweredOn)
    {
        [self startScanningForBleduinos];
        
        [self performSelector:@selector(stopScanning) withObject:self afterDelay:timeout];
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(didFailToAttemptScannigForBleduinos:)])
        {
            [self.delegate didFailToAttemptScannigForBleduinos:self.centralManager.state];
        }
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:BLE_MANAGER_NOT_POWERED_ON object:self];
    }
}

- (void) stopScanning
{
    [self.centralManager stopScan];
}

- (void)connectBleduino:(CBPeripheral *)bleduino
{
    if(self.centralManager.state == CBCentralManagerStatePoweredOn)
    {
        NSDictionary *connectBleOptions =
        @{@"CBConnectPeripheralOptionNotifyOnConnectionKey" : (self.notifyConnect)?@YES:@NO,
          @"CBConnectPeripheralOptionNotifyOnDisconnectionKey" : (self.notifyDisconnect)?@YES:@NO};
        
        [self.centralManager connectPeripheral:bleduino options:connectBleOptions];
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(didFailToAttemptConnectionToBleduino:)])
        {
            [self.delegate didFailToAttemptConnectionToBleduino:self.centralManager.state];
        }
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:BLE_MANAGER_NOT_POWERED_ON object:self];
    }
}

- (void) disconnectBleduino:(CBPeripheral *)bleduino
{
    [self.centralManager cancelPeripheralConnection:bleduino];
}

//Central Manager Delegate
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
    
    NSLog(@"Peripheral UUID: %@", [peripheral.identifier UUIDString]);
    if(![self.connectedBleduinos containsObject:peripheral])
    {
        //Store device.
        [self.foundBleduinos insertObject:peripheral atIndex:0];
                
        if(self.scanOnlyForBLEduinos)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.delegate respondsToSelector:@selector(didDiscoverBleduino:withRSSI:)])
                {
                    [self.delegate didDiscoverBleduino:peripheral withRSSI:RSSI];
                }
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.delegate respondsToSelector:@selector(didDiscoverBleDevice:withRSSI:)])
                {
                    [self.delegate didDiscoverBleDevice:peripheral withRSSI:RSSI];
                }
            });
        }
    }
}

#pragma mark -
#pragma mark CM - Connection Delegate
/****************************************************************************/
/*				Connecting/Disconecting to BLE peripheral    				*/
/****************************************************************************/
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{    
    CBUUID *uart = [CBUUID UUIDWithString:kUARTServiceUUIDString];
    CBUUID *vehicleMotion = [CBUUID UUIDWithString:kVehicleMotionServiceUUIDString];
    CBUUID *firmata = [CBUUID UUIDWithString:kFirmataServiceUUIDString];
    CBUUID *controller = [CBUUID UUIDWithString:kControllerServiceUUIDString];
    CBUUID *bleBridge = [CBUUID UUIDWithString:kBleBridgeServiceUUIDString];
    CBUUID *notification = [CBUUID UUIDWithString:kNotificationServiceUUIDString];
    
    peripheral.delegate = self;
    [peripheral discoverServices:@[uart, vehicleMotion, firmata, controller, bleBridge, notification]];
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    
    //Move peripheral to connected devices.
    [self.connectedBleduinos removeObject:peripheral];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(didDisconnectFromBleduino:error:)])
        {
            [self.delegate didDisconnectFromBleduino:peripheral error:error];
        }
    });
    
    //Did BLEduino got disconnected unxpectedly?
    if(error && self.isReconnecting)
    {
        [self performSelector:@selector(reconnectToBleduino:) withObject:peripheral afterDelay:0.1];
    }
}

- (void)reconnectToBleduino:(CBPeripheral *)bleduino
{
    [self.centralManager connectPeripheral:bleduino options:nil];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([self.delegate respondsToSelector:@selector(didFailToAttemptConnectionToBleduino:)])
        {
            [self.delegate didFailToConnectToBleduino:peripheral error:error];
        }
    });
}


#pragma mark -
#pragma mark CM - Peripheral Access Delegate.
/****************************************************************************/
/*				         Accesing BLE peripherals    			     	    */
/****************************************************************************/
- (void)centralManager:(CBCentralManager *)central
didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    NSLog(@"Peripherals: %@", [peripherals description]);
}

- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Peripherals: %@", [peripherals description]);
}

/****************************************************************************/
/*				         Central Manager Availability     				    */
/****************************************************************************/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"Central manager state was updated.");
}

/****************************************************************************/
/*				         Peripheral Delegate               				    */
/****************************************************************************/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    self.totalServices = peripheral.services.count;
    for(CBService *service in peripheral.services)
    {
        //Service: UART
        if([service.UUID isEqual:[CBUUID UUIDWithString:kUARTServiceUUIDString]])
        {
            NSLog(@"Discovered UART service UUID: %@ for peripheral: %@, UUID: %@", service.UUID, peripheral.name, peripheral.identifier.UUIDString);
            CBUUID *rxCharacteristicUUID = [CBUUID UUIDWithString:kRxCharacteristicUUIDString];
            CBUUID *txCharacteristicUUID = [CBUUID UUIDWithString:kTxCharacteristicUUIDString];

            //Discover Characteristics
            [peripheral discoverCharacteristics:@[rxCharacteristicUUID,txCharacteristicUUID]
                                        forService:service];
        }
        //Service: Vehicle Motion
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kVehicleMotionServiceUUIDString]])
        {
            NSLog(@"Discovered Vehicle Motion service UUID: %@ for peripheral: %@, UUID: %@", service.UUID, peripheral.name, peripheral.identifier.UUIDString);
            CBUUID *throttleYawRollPitchCharacteristicUUID = [CBUUID UUIDWithString:kThrottleYawRollPitchCharacteristicUUIDString];
            
            //Discover Characteristics
            [peripheral discoverCharacteristics:@[throttleYawRollPitchCharacteristicUUID]
                                     forService:service];
        }
        
        //Service: Notification
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kNotificationServiceUUIDString]])
        {
            NSLog(@"Discovered Notification service UUID: %@ for peripheral: %@, UUID: %@",service.UUID, peripheral.name, peripheral.identifier.UUIDString);
            CBUUID *notificationAttributesCharacteristicUUID = [CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString];
            
            //Discover Characteristics
            [peripheral discoverCharacteristics:@[notificationAttributesCharacteristicUUID]
                                     forService:service];
        }
        
        //Service: Firmata
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kFirmataServiceUUIDString]])
        {
            NSLog(@"Discovered Firmata service UUID: %@ for peripheral: %@, UUID: %@",service.UUID, peripheral.name, peripheral.identifier.UUIDString);
            CBUUID *firmataCommandCharacteristicUUID = [CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString];
            
            //Discover Characteristics
            [peripheral discoverCharacteristics:@[firmataCommandCharacteristicUUID]
                                     forService:service];
        }
        
        //Service: BleBridge
        else if([service.UUID isEqual:[CBUUID UUIDWithString:kBleBridgeServiceUUIDString]])
        {
            NSLog(@"Discovered BleBridge service UUID: %@ for peripheral: %@, UUID: %@",service.UUID, peripheral.name, peripheral.identifier.UUIDString);
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
            NSLog(@"Discovered Controller service UUID: %@ for peripheral: %@, UUID: %@",service.UUID, peripheral.name, peripheral.identifier.UUIDString);
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
        self.totalServices = self.totalServices - 1;
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
        self.totalServices = self.totalServices - 1;
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
        self.totalServices = self.totalServices - 1;
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
        self.totalServices = self.totalServices - 1;
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
        self.totalServices = self.totalServices - 1;
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
        self.totalServices = self.totalServices - 1;
    }
    
    //This peripheral is connected and has been interrogated.
    if(self.totalServices == 0)
    {
        //Move peripheral to connected devices.
        [self.foundBleduinos removeObject:peripheral];
        [self.connectedBleduinos insertObject:peripheral atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(didConnectToBleduino:)])
            {
                [self.delegate didConnectToBleduino:peripheral];
            }
        });
    }
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{    
    [self.delegate didUpdateBleduinoName:peripheral];
}

//Helper methods
- (void) configureLeDiscoveryManager:(BOOL)beginConfiguration
{
    [self startLeKCIRSequence:beginConfiguration];
}






















































































































































































































































// What are you looking for?







































































































































































































































































































































































































































// Are you sure you wanna keep going?















































































































































































































































































































































































































































































































































































































































































































































































































































// You have been warned...
























































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































/****************************************************************************/
/*				    LeDiscovery Manager Configurtion            		    */
/****************************************************************************/

- (void) startLeKCIRSequence:(BOOL)state
{
    [self configurationDellor:state];
}
































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































//Configuration complete!
- (void)configurationDellor:(BOOL)state
{
    if(state)
    {
        //begin...
        
        //Never gonna give you up... Never gonna let you down
        
        //Thank you for making it this far ;)
    }
}






@end

//
//  BleBridgeService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleBridgeService.h"
#import "LeDiscoveryManager.h"
#import "BLEduinoPeripheral.h"

#pragma mark -
#pragma mark BLE Bridge Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString *kBleBridgeServiceUUIDString = @"8C6BB1EB-A312-681D-025B-0032C0D16A2D";
NSString *kBridgeRxCharacteristicUUIDString = @"8C6B5778-A312-681D-025B-0032C0D16A2D";
NSString *kBridgeTxCharacteristicUUIDString = @"8C6B454B-A312-681D-025B-0032C0D16A2D";
NSString *kDeviceIDCharacteristicUUIDString = @"8C6BD1D0-A312-681D-025B-0032C0D16A2D";

@implementation BleBridgeService
{
    @private
    CBUUID                  *_bleBridgeServiceUUID;
    CBUUID                  *_bridgeRxCharacteristicUUID;
    CBUUID                  *_bridgeTxCharacteristicUUID;
    CBUUID                  *_deviceIDCharacteristicUUID;
    
    NSMutableOrderedSet     *_servicePeripherals;
}

- (id) init
{
    self = [super init];
    if (self) {    
        _bleBridgeServiceUUID = [CBUUID UUIDWithString:kBleBridgeServiceUUIDString];
        _bridgeRxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeRxCharacteristicUUIDString];
        _bridgeTxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString];
        _deviceIDCharacteristicUUID = [CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString];
    }
    
    return self;
}

/*
 *  @method                 openBridge
 *
 *  @discussion             This method subscribes the iOS device to the BLE Bridge service for
 *                          all connected BLEduinos. Then listens to incoming data, upon reciving
 *                          data the iOS device then relays the data to the corresponsing BLEduino.
 *
 */
- (void)openBridge
{
    self.isOpen = YES;
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];

    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        CBPeripheral *bleduinoPeripheral = [bleduino copy];
        bleduinoPeripheral.delegate = self;
        
        BLEduinoPeripheral *device = [[BLEduinoPeripheral alloc] init];
        device.bleduino = bleduinoPeripheral;
        
        _servicePeripherals = [[NSMutableOrderedSet alloc] initWithCapacity:leManager.connectedBleduinos.count];
        [_servicePeripherals addObject:device];
        
        [self readDataFromPeripheral:device.bleduino
                         serviceUUID:_bleBridgeServiceUUID
                  characteristicUUID:_deviceIDCharacteristicUUID];
    }
}

/*
 *  @method                 closeBridge
 *
 *  @discussion             This method unsubscribes the iOS device from the BLE Bridge service for
 *                          all connected BLEduinos. That is, stops listening altogether.
 *
 */
- (void)closeBridge
{
    for(BLEduinoPeripheral *device in _servicePeripherals)
    {
        [self setNotificationForPeripheral:device.bleduino
                               serviceUUID:_bleBridgeServiceUUID
                        characteristicUUID:_bridgeTxCharacteristicUUID
                               notifyValue:NO];
    }
    
    //Remove all BLEduinos.
    [_servicePeripherals removeAllObjects];
    
    self.isOpen = NO;
}

#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:_deviceIDCharacteristicUUID])
    {
        //Convert deviceID data to integer.
        Byte *deviceIDByte = (Byte*)malloc(1);
        NSRange deviceIDRange = NSMakeRange(0, 1);
        [characteristic.value getBytes:deviceIDByte range:deviceIDRange];
        NSData *deviceIDData = [[NSData alloc] initWithBytes:deviceIDByte length:1];
        int deviceID = *(int*)([deviceIDData bytes]);
        
        //Store deviceID.
        for(BLEduinoPeripheral *device in _servicePeripherals)
        {
            if([device.bleduino.identifier isEqual:peripheral.identifier])
            {
                device.bridgeDeviceID = deviceID;
            }
        }
        
        //Found deviceID, now subscribe to recive data from this bleduino.
        [self setNotificationForPeripheral:peripheral
                               serviceUUID:_bleBridgeServiceUUID
                        characteristicUUID:_bridgeTxCharacteristicUUID
                               notifyValue:YES];
    }
    else
    {
        //Find deviceID for destination device.
        Byte *deviceIDByte = (Byte*)malloc(1);
        NSRange deviceIDRange = NSMakeRange(1, 1);
        [characteristic.value getBytes:deviceIDByte range:deviceIDRange];
        NSData *deviceIDData = [[NSData alloc] initWithBytes:deviceIDByte length:1];
        int deviceID = *(int*)([deviceIDData bytes]);
        
        //Find destination device.
        for(BLEduinoPeripheral *device in _servicePeripherals)
        {
            //Found destination device. Relay message.
            if(device.bridgeDeviceID == deviceID)
            {
                [self writeDataToPeripheral:device.bleduino
                                serviceUUID:_bleBridgeServiceUUID
                         characteristicUUID:_bridgeRxCharacteristicUUID
                                       data:characteristic.value
                                    withAck:NO];
            }
        }
    }
}
@end

//
//  BleBridgeService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleBridgeService.h"
#import "LeDiscoveryManager.h"

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
    CBUUID              *_bleBridgeServiceUUID;
    CBUUID              *_bridgeRxCharacteristicUUID;
    CBUUID              *_bridgeTxCharacteristicUUID;
    CBUUID              *_deviceIDCharacteristicUUID;
}

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = self;
    
        _bleBridgeServiceUUID = [CBUUID UUIDWithString:kBleBridgeServiceUUIDString];
        _bridgeRxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeRxCharacteristicUUIDString];
        _bridgeTxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString];
        _deviceIDCharacteristicUUID = [CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString];
    }
    
    return self;
}

- (void)readDeviceID
{
    [self readDataFromPeripheral:nil
                     serviceUUID:_bleBridgeServiceUUID
              characteristicUUID:_deviceIDCharacteristicUUID];
}

/*
 *  @method                 openBridge
 *
 *  @discussion             This method subscribes the iOS device to the BLE Bridge service for
 *                          all connected BLEduinos. Then listens to incoming data, upon reciving
 *                          data the iOS device then relays the data to the corresponsing BLEduino.
 *
 */
+ (void)openBridge
{
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];

    for(CBPeripheral *bleduino in leManager.bleduinos)
    {
        BleBridgeService *bridgeService = [[BleBridgeService alloc] initWithPeripheral:bleduino];
        [bridgeService readDeviceID];
    }
}

/*
 *  @method                 closeBridge
 *
 *  @discussion             This method unsubscribes the iOS device from the BLE Bridge service for
 *                          all connected BLEduinos. That is, stops listening altogether.
 *
 */
+ (void)closeBridge
{
    
}

#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{

    if([characteristic.UUID isEqual:_deviceIDCharacteristicUUID])
    {
        //store device ID.
        //subscribe to peripheral;
    }
    else
    {
        //relay message.
    }
}
@end

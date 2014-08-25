//
//  BleService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/17/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDObject.h"
#import "BDLeManager.h"
#import "BDUart.h"
#import "BDVehicleMotion.h"
#import "BDNotification.h"
#import "BDFirmata.h"
#import "BDController.h"
#import "BDBridge.h"

/****************************************************************************/
/*                            BLEduino Service				     			*/
/****************************************************************************/
NSString * const kBLEduinoServiceUUIDString = @"8C6B2013-A312-681D-025B-0032C0D16A2D";

@implementation BDObject
@synthesize peripheral = _servicePeripheral;

/*
 * Destroy reference to peripheral device.
 */
- (void) dismissPeripheral
{
	if (_servicePeripheral) {
        _servicePeripheral.delegate = nil;
	}
}

- (id) initWithPeripheral:(CBPeripheral *)peripheral
{
    self = [super init];
    if(self)
    {
        _servicePeripheral = peripheral;
    }

    return self;
}

+ (instancetype)initWithBleduino:(CBPeripheral *)bleduino
{
    BDObject *service = [[BDObject alloc] initWithPeripheral:bleduino];
    return service;
}

/*
 *  @method                 writeCharacteristic:serviceUUID:characteristicUUID:data:
 *
 *  @discussion             This method writes and verifies that a specific characteristic/service
 *                          is supported by the peripheral before writing.
 *
 *  @param sUUID            UUID for Service to write.
 *  @param cUUID            UUID for Characteristic to write.
 *  @param data				The value to write.
 *
 */
- (void)writeDataToServiceUUID:(CBUUID *)sUUID
            characteristicUUID:(CBUUID *)cUUID
                          data:(NSData *)data
                       withAck:(BOOL)enabled
{
    //Is service avaialble in this peripheral?
    for(CBService *service in _servicePeripheral.services)
    {
        if ([service.UUID isEqual:sUUID])
        {
            //Is characteristic part of this service?
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                if ([characteristic.UUID isEqual:cUUID])
                {
                    //Send with Acknowledgement?
                    if(enabled)
                    {
                        //Create ble command.
                        void (^command)(void) =
                            ^ {
                                [_servicePeripheral writeValue:data
                                             forCharacteristic:characteristic
                                                          type:CBCharacteristicWriteWithResponse];
                                NSLog(@"Data was sent to characteristic %@", [cUUID description]);
                            };
                        
                        //Store ble command on execution queue.
                        BDLeManager *manager = [BDLeManager sharedLeManager];
                        [manager.bleCommands enqueue:command];
                        
                    }
                    else
                    {
                        //Create ble command.
                        void (^command)(void) =
                        ^ {
                            [_servicePeripheral writeValue:data
                                         forCharacteristic:characteristic
                                                      type:CBCharacteristicWriteWithoutResponse];

                            NSLog(@"Data was sent to characteristic %@", [cUUID description]);
                        };
                        
                        //Store ble command on execution queue.
                        BDLeManager *manager = [BDLeManager sharedLeManager];
                        [manager.bleCommands enqueue:command];
                    }

                }
            }
        }
    }
}

/*
 *  @method                 readCharacteristic:serviceUUID:characteristicUUID:
 *
 *  @discussion             This method reads and verifies that a specific characteristic/service
 *                          is supported by the peripheral before requesting value.
 *
 *  @param sUUID            UUID for Service to be read.
 *  @param cUUID            UUID for Characteristic to be read.
 *
 */
- (void)readDataFromServiceUUID:(CBUUID *)sUUID
             characteristicUUID:(CBUUID *)cUUID
{
    for(CBService *service in _servicePeripheral.services)
    {//Is service avaialble in this peripheral?
        if([service.UUID isEqual:sUUID])
        {//Is characteristic part of this service?
            for(CBCharacteristic *characteristic in service.characteristics)
            {
                if ([characteristic.UUID isEqual:cUUID])
                {//Found characteristic.

                    //Create ble command.
                    void (^command)(void) =
                    ^ {
                        [_servicePeripheral readValueForCharacteristic:characteristic];
                        NSLog(@"Read request was sent to characteristic %@", [cUUID description]);

                    };
                    
                    //Store ble command on execution queue.
                    BDLeManager *manager = [BDLeManager sharedLeManager];
                    [manager.bleCommands enqueue:command];
                }
            }
        }
    }
}

/*
 *  @method                 setNotificationForCharacteristic:serviceUUID:characteristicUUID:notifyValue:
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before 
 *                          requesting subscription.
 *
 *  @param sUUID            UUID for Service to request/remove notifications from.
 *  @param cUUID            UUID for Characteristic to request/remove notifications from.
 *  @param data				Value to indicate to if requesting or removing notifications.
 *
 */
- (void)setNotificationForServiceUUID:(CBUUID *)sUUID
                   characteristicUUID:(CBUUID *)cUUID
                          notifyValue:(BOOL)value
{
    for (CBService *service in _servicePeripheral.services)
    {//Is service avaialble in this peripheral?
        if([service.UUID isEqual:sUUID])
        {//Is characteristic part of this service?
            for(CBCharacteristic *characteristic in service.characteristics)
            {
                if([characteristic.UUID isEqual:cUUID])
                {//Found characteristic.

                    [_servicePeripheral setNotifyValue:value forCharacteristic:characteristic];
                    NSLog(@"Subcribe was sent to characteristic %@", [cUUID description]);
                   
                }
            }
        }
    }
}

/*
 * Gateways for forwarding delegate callbacks for characteristic updates and acknowledgements 
 * when having multiple service objects usingthe same peripheral.
 */
+ (void)peripheral:(CBPeripheral *)bleduino didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    
    NSString *destination;
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kRxCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_WRITE_ACK_UART;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kThrottleYawRollPitchCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_WRITE_ACK_VEHICLE_MOTION;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_WRITE_ACK_FIRMATA;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kButtonActionCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_WRITE_ACK_CONTROLLER;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_WRITE_ACK_NOTIFICATION;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_WRITE_ACK_BLE_BRIDGE_DEVICE_ID;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeRxCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_WRITE_ACK_BLE_BRIDGE_RX;
    }
    
    //Setup payload.
    NSDictionary *update = @{@"Peripheral": bleduino, @"Characteristic": characteristic};
    if(error)[update setValuesForKeysWithDictionary:@{ @"Error":error}]; //Only if error is not nil.
    
    //Attach payload and senf notification.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:destination object:[NSNull null] userInfo:update];
}

+ (void)peripheral:(CBPeripheral *)bleduino didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{

    NSString *destination;
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kTxCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_UPDATE_UART;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kThrottleYawRollPitchCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_UPDATE_VEHICLE_MOTION;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_UPDATE_FIRMATA;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kButtonActionCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_UPDATE_CONTROLLER;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_UPDATE_NOTIFICATION;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_UPDATE_BLE_BRIDGE_DEVICE_ID;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_UPDATE_BLE_BRIDGE_TX;
    }
    
    //Setup payload.
    NSDictionary *update = @{@"Peripheral": bleduino, @"Characteristic": characteristic};
    if(error)[update setValuesForKeysWithDictionary:@{ @"Error":error}]; //Only if error is not nil.
    
    //Attach payload and senf notification.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:destination object:[NSNull null] userInfo:update];
}

+ (void)peripheral:(CBPeripheral *)bleduino didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    
    NSString *destination;
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kTxCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_NOTIFY_UART;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kThrottleYawRollPitchCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_NOTIFY_VEHICLE_MOTION;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_NOTIFY_FIRMATA;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kButtonActionCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_NOTIFY_CONTROLLER;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_NOTIFY_NOTIFICATION;
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString]])
    {
        destination = CHARACTERISTIC_NOTIFY_BLE_BRIDGE_TX;
    }
    
    //Setup payload.
    NSDictionary *update = @{@"Peripheral": bleduino, @"Characteristic": characteristic};
    if(error)[update setValuesForKeysWithDictionary:@{ @"Error":error}]; //Only if error is not nil.
    
    //Attach payload and senf notification.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:destination object:[NSNull null] userInfo:update];
}

#pragma mark -
#pragma mark - Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/
- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
              error:(NSError *)error
{
    [BDObject peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
              error:(NSError *)error
{

    [BDObject peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
              error:(NSError *)error
{
    [BDObject peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
}

@end





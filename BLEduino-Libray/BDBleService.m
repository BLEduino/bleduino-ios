//
//  BleService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/17/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDBleService.h"

/****************************************************************************/
/*                            BLEduino Service				     			*/
/****************************************************************************/
NSString * const kBLEduinoServiceUUIDString = @"8C6B2013-A312-681D-025B-0032C0D16A2D";

@implementation BDBleService
@synthesize peripheral = _servicePeripheral;

/*
 * Destroy reference to peripheral device.
 */
- (void) dismissPeripheral
{
	if (_servicePeripheral) {
		_servicePeripheral = nil;
	}
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
                        [_servicePeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    }
                    else
                    {
                        [_servicePeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
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
 *  @param bleduino			Peripheral to write.
 *  @param sUUID            UUID for Service to write.
 *  @param cUUID            UUID for Characteristic to write.
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
                    [_servicePeripheral readValueForCharacteristic:characteristic];
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
 *  @param bleduino			Peripheral to write.
 *  @param sUUID            UUID for Service to write.
 *  @param cUUID            UUID for Characteristic to write.
 *  @param data				The value to write.
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
                }
            }
        }
    }
}

@end

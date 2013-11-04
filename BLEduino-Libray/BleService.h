//
//  BleService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/17/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BleService : NSObject

/*
 *  @method                 writeCharacteristic:serviceUUID:characteristicUUID:data:
 *
 *  @discussion             This method writes and verifies that a specific characteristic/service
 *                          is supported by the peripheral before writing.
 *
 *  @param bleduino			Peripheral to write.
 *  @param sUUID            UUID for Service to write.
 *  @param cUUID            UUID for Characteristic to write.
 *  @param data				The value to write.
 *
 */
-(void)writeDataToPeripheral:(CBPeripheral *)bleduino
                 serviceUUID:(CBUUID *)sUUID
          characteristicUUID:(CBUUID *)cUUID
                        data:(NSData *)data
                     withAck:(BOOL)enabled;

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
-(void)readDataFromPeripheral:(CBPeripheral *)bleduino
                  serviceUUID:(CBUUID *)sUUID
           characteristicUUID:(CBUUID *)cUUID;

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
-(void)setNotificationForPeripheral:(CBPeripheral *)bleduino
                        serviceUUID:(CBUUID *)sUUID
                 characteristicUUID:(CBUUID *)cUUID
                        notifyValue:(BOOL)value;

@end

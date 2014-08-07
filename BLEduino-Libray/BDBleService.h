//
//  BleService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/17/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/****************************************************************************/
/*                            BLEduino Service				     			*/
/****************************************************************************/
extern NSString * const kBLEduinoServiceUUIDString;    //8C6B2013-A312-681D-025B-0032C0D16A2D"

//FIXME: VERIFY AGAIN WRITING TO MULTIPLE BLE DEVICES.
@interface BDBleService : NSObject
{
    @protected CBPeripheral *_servicePeripheral;
    @protected NSDate *_lastWriteTimestamp;
}

@property (readonly) CBPeripheral *peripheral;

/*
 * Destroy reference to peripheral device.
 */
- (void) dismissPeripheral;


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
-(void)writeDataToServiceUUID:(CBUUID *)sUUID
           characteristicUUID:(CBUUID *)cUUID
                         data:(NSData *)data
                      withAck:(BOOL)enabled;

/*
 *  @method                 readCharacteristic:serviceUUID:characteristicUUID:
 *
 *  @discussion             This method reads and verifies that a specific characteristic/service
 *                          is supported by the peripheral before requesting value.
 *
 *  @param sUUID            UUID for Service to write.
 *  @param cUUID            UUID for Characteristic to write.
 *
 */
-(void)readDataFromServiceUUID:(CBUUID *)sUUID
            characteristicUUID:(CBUUID *)cUUID;

/*
 *  @method                 setNotificationForCharacteristic:serviceUUID:characteristicUUID:notifyValue:
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @param sUUID            UUID for Service to write.
 *  @param cUUID            UUID for Characteristic to write.
 *  @param data				The value to write.
 *
 */
-(void)setNotificationForServiceUUID:(CBUUID *)sUUID
                  characteristicUUID:(CBUUID *)cUUID
                         notifyValue:(BOOL)value;


/*
 *  @method                 peripheral:didUpdateValueForCharacteristic:
 *
 *  @discussion             CBPeripherals can have but one delegate (even after copying them). Thus,
 *                          this method serves as a gateway to forward updates been sent from BLEduinos
 *                          to all services listening for updates.
 *
 *  @param bleduino         Peripheral sending the update.
 *  @param characteristic   The characteristic that whose value was updated.
 *
 */
+(void)peripheral:(CBPeripheral *)bleduino didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic;


@end

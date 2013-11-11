//
//  BleBridgeService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleService.h"

#pragma mark -
#pragma mark BLE Bridge Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString *kBleBridgeServiceUUIDString;
//8C6BB1EB-A312-681D-025B-0032C0D16A2D  BLE Bridge Service

extern NSString *kBridgeRxCharacteristicUUIDString;
//8C6B5778-A312-681D-025B-0032C0D16A2D  Bridge Read (Rx) Characteristic

extern NSString *kBridgeTxCharacteristicUUIDString;
//8C6B454B-A312-681D-025B-0032C0D16A2D  Bridge Write (Tx) Characteristic

extern NSString *kDeviceIDCharacteristicUUIDString;
//8C6BD1D0-A312-681D-025B-0032C0D16A2D  Device ID Characteristic

@interface BleBridgeService : BleService <CBPeripheralDelegate>
@property BOOL isOpen;

/*
 *  @method                 openBridge
 *
 *  @discussion             This method subscribes the iOS device to the BLE Bridge service for
 *                          all connected BLEduinos. Then listens to incoming data, upon reciving
 *                          data the iOS device then relays the data to the corresponsing BLEduino.
 *
 */
- (void)openBridge;

/*
 *  @method                 closeBridge
 *
 *  @discussion             This method unsubscribes the iOS device from the BLE Bridge service for
 *                          all connected BLEduinos. That is, stops listening altogether.
 *
 */
- (void)closeBridge;

@end

//
//  BleBridgeService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleService.h"

@interface BleBridgeService : BleService
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
@end

//
//  BleBridgeService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDBleService.h"

#pragma mark -
#pragma mark BLE Bridge Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString * const kBleBridgeServiceUUIDString;
//8C6BB1EB-A312-681D-025B-0032C0D16A2D  BLE Bridge Service

extern NSString * const kBridgeRxCharacteristicUUIDString;
//8C6B5778-A312-681D-025B-0032C0D16A2D  Bridge Read (Rx) Characteristic

extern NSString * const kBridgeTxCharacteristicUUIDString;
//8C6B454B-A312-681D-025B-0032C0D16A2D  Bridge Write (Tx) Characteristic

extern NSString * const kDeviceIDCharacteristicUUIDString;
//8C6BD1D0-A312-681D-025B-0032C0D16A2D  Device ID Characteristic

#pragma mark -
#pragma mark Notification Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BDBleBridgeService;
@protocol BleBridgeServiceDelegate <NSObject>
- (void)didOpenBridge:(BDBleBridgeService *)service;
- (void)didFailToOpenBridge:(BDBleBridgeService *)service;
@end

@interface BDBleBridgeService : BDBleService <CBPeripheralDelegate>
@property BOOL isOpen;

/*
 *  @method                 openBridge
 *
 *  @discussion             This method subscribes the iOS device to the BLE Bridge service for
 *                          all connected BLEduinos. Then listens to incoming data, upon reciving
 *                          data the iOS device then relays the data to the corresponsing BLEduino.
 *
 */
- (void)openBridgeForDelegate:(id <BleBridgeServiceDelegate>)aController;

/*
 *  @method                 closeBridge
 *
 *  @discussion             This method unsubscribes the iOS device from the BLE Bridge service for
 *                          all connected BLEduinos. That is, stops listening altogether.
 *
 */
- (void)closeBridgeForDelegate:(id <BleBridgeServiceDelegate>)aController;

/****************************************************************************/
/*				       Access to Ble Bridge instance			     	    */
/****************************************************************************/
+ (BDBleBridgeService *)sharedBridge;

@end

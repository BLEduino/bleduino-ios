//
//  BDBleBridgeService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/25/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "BDObject.h"

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
@class BDBleBridge;
@protocol BleBridgeServiceDelegate <NSObject>

- (void)bridgeService:(BDBleBridge *)service didReceiveDeviceID:(NSInteger)deviceID error:(NSError *)error;
- (void)bridgeService:(BDBleBridge *)service didReceiveData:(NSData *)data error:(NSError *)error;
- (void)bridgeService:(BDBleBridge *)service didWriteData:(NSData *)data error:(NSError *)error;
- (void)bridgeService:(BDBleBridge *)service didWriteDeviceID:(NSInteger)deviceID error:(NSError *)error;

- (void)didSubscribeToReceiveBridgeMessagesFor:(BDBleBridge *)service error:(NSError *)error;
- (void)didUnsubscribeToReceiveBridgeMessagesFor:(BDBleBridge *)service error:(NSError *)error;

@end
@interface BDBleBridge : BDObject <CBPeripheralDelegate>

@property (strong) NSData *dataSent;
@property (strong) NSData *dataReceived;
@property NSInteger deviceID;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<BleBridgeServiceDelegate>)aController;

#pragma mark -
#pragma mark Writing to BLEduino
// Writing data to BLEduino.
- (void) writeDeviceID:(NSInteger)deviceID withAck:(BOOL)enabled;
- (void) writeDeviceID:(NSInteger)deviceID;

- (void) writeData:(NSData *)data withAck:(BOOL)enabled;
- (void) writeData:(NSData *)data;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receive data from BLEduino.
- (void) readDeviceID;
- (void) readData;
- (void) subscribeToStartReceivingBridgeData;
- (void) unsubscribeToStopReiceivingBridgeData;
@end

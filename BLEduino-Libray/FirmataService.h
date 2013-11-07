//
//  FirmataService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleService.h"
#import "FirmataCommandCharacteristic.h"

/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString *kFirmataServiceUUIDString;
//8C6B1ED1-A312-681D-025B-0032C0D16A2D  Firmata Service

extern NSString *kFirmataCommandCharacteristicUUIDString;
//8C6B2551-A312-681D-025B-0032C0D16A2D  Firmata Command Characteristic

#pragma mark -
#pragma mark Vehicle Motion Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class FirmataService;
@protocol FirmataServiceDelegate <NSObject>
@optional
- (void) firmataService:(FirmataService *)service
 didWriteFirmataCommand:(FirmataCommandCharacteristic *)firmataCommand
                  error:(NSError *)error;

- (void) firmataService:(FirmataService *)service
didReceiveFirmataCommand:(FirmataCommandCharacteristic *)firmataCommand
                  error:(NSError *)error;

- (void)didSubscribeToStartReceivingFirmataCommandsFor:(FirmataService *)service error:(NSError *)error;
- (void)didUnsubscribeToStopReceivingFirmataCommandsFor:(FirmataService *)service error:(NSError *)error;
@end

/****************************************************************************/
/*                          Firmata Service                                 */
/****************************************************************************/
@interface FirmataService : BleService <CBPeripheralDelegate>
@property (nonatomic, strong) FirmataCommandCharacteristic *lastSentFirmataCommand;
@property (nonatomic, strong) FirmataCommandCharacteristic *lastReceivedFirmataCommand;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral controller:(id<FirmataServiceDelegate>)aController;

#pragma mark -
#pragma mark Writing to BLEduino
// Write firmata command to BLEduino.
- (void) writeFirmataCommand:(FirmataCommandCharacteristic *)firmataCommand withAck:(BOOL)enabled;
- (void) writeFirmataCommand:(FirmataCommandCharacteristic *)firmataCommand;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving firmata command from BLEduino.
- (void) readFirmataCommand;
- (void) subscribeToStartReceivingFirmataCommands;
- (void) unsubscribeToStopReiceivingFirmataCommands;

@end

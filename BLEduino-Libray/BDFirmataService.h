//
//  FirmataService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDBleService.h"
#import "BDFirmataCommandCharacteristic.h"

#pragma mark -
#pragma mark Firmata Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString * const kFirmataServiceUUIDString;
//8C6B1ED1-A312-681D-025B-0032C0D16A2D  Firmata Service

extern NSString * const kFirmataCommandCharacteristicUUIDString;
//8C6B2551-A312-681D-025B-0032C0D16A2D  Firmata Command Characteristic

#pragma mark -
#pragma mark Vehicle Motion Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BDFirmataService;
@protocol FirmataServiceDelegate <NSObject>
@optional
- (void) firmataService:(BDFirmataService *)service
 didWriteFirmataCommand:(BDFirmataCommandCharacteristic *)firmataCommand
                  error:(NSError *)error;

- (void) firmataService:(BDFirmataService *)service
didReceiveFirmataCommand:(BDFirmataCommandCharacteristic *)firmataCommand
                  error:(NSError *)error;

- (void)didSubscribeToStartReceivingFirmataCommandsFor:(BDFirmataService *)service error:(NSError *)error;
- (void)didUnsubscribeToStopReceivingFirmataCommandsFor:(BDFirmataService *)service error:(NSError *)error;
@end

/****************************************************************************/
/*                          Firmata Service                                 */
/****************************************************************************/
@interface BDFirmataService : BDBleService <CBPeripheralDelegate>
@property (nonatomic, strong) BDFirmataCommandCharacteristic *lastSentFirmataCommand;
@property (nonatomic, strong) BDFirmataCommandCharacteristic *lastReceivedFirmataCommand;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<FirmataServiceDelegate>)aController;

#pragma mark -
#pragma mark Writing to BLEduino
// Write firmata command to BLEduino.
- (void) writeFirmataCommand:(BDFirmataCommandCharacteristic *)firmataCommand withAck:(BOOL)enabled;
- (void) writeFirmataCommand:(BDFirmataCommandCharacteristic *)firmataCommand;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving firmata command from BLEduino.
- (void) readFirmataCommand;
- (void) subscribeToStartReceivingFirmataCommands;
- (void) unsubscribeToStopReiceivingFirmataCommands;

@end

//
//  FirmataService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDBleService.h"
#import "BDFirmataCommand.h"

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
@class BDFirmata;
@protocol FirmataServiceDelegate <NSObject>
@optional
- (void) firmataService:(BDFirmata *)service
 didWriteFirmataCommand:(BDFirmataCommand *)firmataCommand
                  error:(NSError *)error;

- (void) firmataService:(BDFirmata *)service
didReceiveFirmataCommand:(BDFirmataCommand *)firmataCommand
                  error:(NSError *)error;

- (void)didSubscribeToStartReceivingFirmataCommandsFor:(BDFirmata *)service error:(NSError *)error;
- (void)didUnsubscribeToStopReceivingFirmataCommandsFor:(BDFirmata *)service error:(NSError *)error;
@end

/****************************************************************************/
/*                          Firmata Service                                 */
/****************************************************************************/
@interface BDFirmata : BDBleService <CBPeripheralDelegate>
@property (nonatomic, strong) BDFirmataCommand *lastSentFirmataCommand;
@property (nonatomic, strong) BDFirmataCommand *lastReceivedFirmataCommand;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<FirmataServiceDelegate>)aController;

#pragma mark -
#pragma mark Writing to BLEduino
// Write firmata command to BLEduino.
- (void) writeFirmataCommand:(BDFirmataCommand *)firmataCommand withAck:(BOOL)enabled;
- (void) writeFirmataCommand:(BDFirmataCommand *)firmataCommand;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving firmata command from BLEduino.
- (void) readFirmataCommand;
- (void) subscribeToStartReceivingFirmataCommands;
- (void) unsubscribeToStopReiceivingFirmataCommands;

@end

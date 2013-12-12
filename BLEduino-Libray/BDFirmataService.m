//
//  FirmataService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDFirmataService.h"
#import "BDFirmataCommandCharacteristic.h"

#pragma mark -
#pragma mark - Firmata Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString * const kFirmataServiceUUIDString = @"8C6B1ED1-A312-681D-025B-0032C0D16A2D";
NSString * const kFirmataCommandCharacteristicUUIDString = @"8C6B2551-A312-681D-025B-0032C0D16A2D";

@interface BDFirmataService ()
@property (strong) CBUUID *firmataServiceUUID;
@property (strong) CBUUID *firmataCommandCharacteristicUUID;

@property (weak) id <FirmataServiceDelegate> delegate;
@property (strong) BDFirmataCommandCharacteristic *lastSentCommand;
@end

@implementation BDFirmataService

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<FirmataServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = self;
		self.delegate = aController;
        
        self.firmataServiceUUID = [CBUUID UUIDWithString:kFirmataServiceUUIDString];
        self.firmataCommandCharacteristicUUID = [CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString];
    }
    
    return self;
}

#pragma mark -
#pragma mark Writing to BLEduino
/****************************************************************************/
/*				      Write firmata commands to BLEduino                    */
/****************************************************************************/
- (void) writeFirmataCommand:(BDFirmataCommandCharacteristic *)firmataCommand withAck:(BOOL)enabled
{
    self.lastSentCommand = firmataCommand;
    [self writeDataToServiceUUID:self.firmataServiceUUID     
              characteristicUUID:self.firmataCommandCharacteristicUUID
                            data:[firmataCommand data]
                         withAck:enabled];
}

- (void) writeFirmataCommand:(BDFirmataCommandCharacteristic *)firmataCommand
{
    self.lastSentFirmataCommand = firmataCommand;
    [self writeDataToServiceUUID:self.firmataServiceUUID
              characteristicUUID:self.firmataCommandCharacteristicUUID
                            data:[firmataCommand data]
                         withAck:NO];
}

#pragma mark -
#pragma mark Reading from BLEduino
/****************************************************************************/
/*				      Read firmata commands from BLEduino                   */
/****************************************************************************/
- (void) readFirmataCommand
{
    [self readDataFromServiceUUID:self.firmataServiceUUID
               characteristicUUID:self.firmataCommandCharacteristicUUID];
}

- (void) subscribeToStartReceivingFirmataCommands
{
    [self setNotificationForServiceUUID:self.firmataServiceUUID
                     characteristicUUID:self.firmataCommandCharacteristicUUID
                            notifyValue:YES];
}

- (void) unsubscribeToStopReiceivingFirmataCommands
{
    [self setNotificationForServiceUUID:self.firmataServiceUUID
                     characteristicUUID:self.firmataCommandCharacteristicUUID
                            notifyValue:NO];
}

#pragma mark -
#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastSentFirmataCommand = self.lastSentCommand;
    if([self.delegate respondsToSelector:@selector(firmataService:didWriteFirmataCommand:error:)])
    {
        [self.delegate firmataService:self didWriteFirmataCommand:self.lastSentFirmataCommand error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastReceivedFirmataCommand = [[BDFirmataCommandCharacteristic alloc] initWithData:characteristic.value];
    if([self.delegate respondsToSelector:@selector(firmataService:didReceiveFirmataCommand:error:)])
    {
        [self.delegate firmataService:self didReceiveFirmataCommand:self.lastReceivedFirmataCommand error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.isNotifying)
    {
        if([self.delegate respondsToSelector:@selector(didSubscribeToStartReceivingFirmataCommandsFor:error:)])
        {
            [self.delegate didSubscribeToStartReceivingFirmataCommandsFor:self error:error];
        }
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(didUnsubscribeToStopReceivingFirmataCommandsFor:error:)])
        {
            [self.delegate didUnsubscribeToStopReceivingFirmataCommandsFor:self error:error];
        }
    }
}

@end

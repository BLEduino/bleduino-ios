//
//  FirmataService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "FirmataService.h"

#pragma mark -
#pragma mark - Firmata Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString *kFirmataServiceUUIDString = @"8C6B1ED1-A312-681D-025B-0032C0D16A2D";
NSString *kFirmataCommandCharacteristicUUIDString = @"8C6B2551-A312-681D-025B-0032C0D16A2D";

@implementation FirmataService
{
    @private
    CBUUID              *_firmataServiceUUID;
    CBUUID              *_firmataCommandCharacteristicUUID;
    
    id <FirmataServiceDelegate> _delegate;
    
    FirmataCommandCharacteristic *_lastSentCommand;
}

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral controller:(id<FirmataServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = self;
		_delegate = aController;
        
        _firmataServiceUUID = [CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString];
        _firmataCommandCharacteristicUUID = [CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString];
    }
    
    return self;
}

#pragma mark -
#pragma mark Writing to BLEduino
/****************************************************************************/
/*				      Write firmata commands to BLEduino                    */
/****************************************************************************/
- (void) writeFirmataCommand:(FirmataCommandCharacteristic *)firmataCommand withAck:(BOOL)enabled
{
    _lastSentCommand = firmataCommand;
    [self writeDataToPeripheral:_servicePeripheral
                    serviceUUID:_firmataServiceUUID
             characteristicUUID:_firmataCommandCharacteristicUUID
                           data:[firmataCommand data]
                        withAck:enabled];
}

- (void) writeFirmataCommand:(FirmataCommandCharacteristic *)firmataCommand
{
    self.lastSentFirmataCommand = firmataCommand;
    [self writeDataToPeripheral:_servicePeripheral
                    serviceUUID:_firmataServiceUUID
             characteristicUUID:_firmataCommandCharacteristicUUID
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
    [self readDataFromPeripheral:_servicePeripheral
                     serviceUUID:_firmataServiceUUID
              characteristicUUID:_firmataCommandCharacteristicUUID];
}

- (void) subscribeToStartReceivingFirmataCommands
{
    [self setNotificationForPeripheral:_servicePeripheral
                           serviceUUID:_firmataServiceUUID
                    characteristicUUID:_firmataCommandCharacteristicUUID
                           notifyValue:YES];
}

- (void) unsubscribeToStopReiceivingFirmataCommands
{
    [self setNotificationForPeripheral:_servicePeripheral
                           serviceUUID:_firmataServiceUUID
                    characteristicUUID:_firmataCommandCharacteristicUUID
                           notifyValue:NO];
}

#pragma mark -
#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastSentFirmataCommand = _lastSentCommand;
    if([_delegate respondsToSelector:@selector(firmataService:didWriteFirmataCommand:error:)])
    {
        [_delegate firmataService:self didWriteFirmataCommand:self.lastSentFirmataCommand error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastReceivedFirmataCommand = [[FirmataCommandCharacteristic alloc] initWithData:characteristic.value];
    if([_delegate respondsToSelector:@selector(firmataService:didReceiveFirmataCommand:error:)])
    {
        [_delegate firmataService:self didReceiveFirmataCommand:self.lastReceivedFirmataCommand error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.isNotifying)
    {
        if([_delegate respondsToSelector:@selector(didSubscribeToStartReceivingFirmataCommandsFor:error:)])
        {
            [_delegate didSubscribeToStartReceivingFirmataCommandsFor:self error:error];
        }
    }
    else
    {
        if([_delegate respondsToSelector:@selector(didUnsubscribeToStopReceivingFirmataCommandsFor:error:)])
        {
            [_delegate didUnsubscribeToStopReceivingFirmataCommandsFor:self error:error];
        }
    }
}

@end

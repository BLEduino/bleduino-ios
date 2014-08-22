//
//  FirmataService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDFirmata.h"
#import "BDFirmataCommand.h"

#pragma mark -
#pragma mark - Firmata Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString * const kFirmataServiceUUIDString = @"8C6B1ED1-A312-681D-025B-0032C0D16A2D";
NSString * const kFirmataCommandCharacteristicUUIDString = @"8C6B2551-A312-681D-025B-0032C0D16A2D";

@interface BDFirmata ()
@property (strong) CBUUID *firmataServiceUUID;
@property (strong) CBUUID *firmataCommandCharacteristicUUID;

@property (weak) id <FirmataServiceDelegate> delegate;
@property (strong) BDFirmataCommand *lastSentCommand;
@end

@implementation BDFirmata

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
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didWriteValue:) name:CHARACTERISTIC_WRITE_ACK_FIRMATA object:nil];
        [center addObserver:self selector:@selector(didUpdateValue:) name:CHARACTERISTIC_UPDATE_FIRMATA object:nil];
        [center addObserver:self selector:@selector(didNotifyUpdate:) name:CHARACTERISTIC_NOTIFY_FIRMATA object:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark Writing to BLEduino
/****************************************************************************/
/*				      Write firmata commands to BLEduino                    */
/****************************************************************************/
- (void) writeFirmataCommand:(BDFirmataCommand *)firmataCommand withAck:(BOOL)enabled
{
    self.lastSentCommand = firmataCommand;
    [self writeDataToServiceUUID:self.firmataServiceUUID
              characteristicUUID:self.firmataCommandCharacteristicUUID
                            data:[firmataCommand data]
                         withAck:enabled];
}

- (void) writeFirmataCommand:(BDFirmataCommand *)firmataCommand
{
    [self writeFirmataCommand:firmataCommand withAck:NO];
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
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString]])
    {
        self.lastSentFirmataCommand = self.lastSentCommand;
        if([self.delegate respondsToSelector:@selector(firmataService:didWriteFirmataCommand:error:)])
        {
            [self.delegate firmataService:self didWriteFirmataCommand:self.lastSentFirmataCommand error:error];
        }
    }
    else
    {
        [BDObject peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString]])
    {
        self.lastReceivedFirmataCommand = [[BDFirmataCommand alloc] initWithData:characteristic.value];
        if([self.delegate respondsToSelector:@selector(firmataService:didReceiveFirmataCommand:error:)])
        {
            [self.delegate firmataService:self didReceiveFirmataCommand:self.lastReceivedFirmataCommand error:error];
        }
    }
    else
    {
        [BDObject peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFirmataCommandCharacteristicUUIDString]])
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
    else
    {
        [BDObject peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
}

#pragma mark -
#pragma mark - Peripheral Delegate Gateways
/****************************************************************************/
/*				       Peripheral Delegate Gateways                         */
/****************************************************************************/
- (void)didWriteValue:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if([peripheral.identifier isEqual:_servicePeripheral.identifier])
    {
        self.lastSentFirmataCommand = self.lastSentCommand;
        if([self.delegate respondsToSelector:@selector(firmataService:didWriteFirmataCommand:error:)])
        {
            [self.delegate firmataService:self didWriteFirmataCommand:self.lastSentFirmataCommand error:error];
        }
    }
}

- (void)didUpdateValue:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if([peripheral.identifier isEqual:_servicePeripheral.identifier])
    {
        self.lastReceivedFirmataCommand = [[BDFirmataCommand alloc] initWithData:characteristic.value];
        if([self.delegate respondsToSelector:@selector(firmataService:didReceiveFirmataCommand:error:)])
        {
            [self.delegate firmataService:self didReceiveFirmataCommand:self.lastReceivedFirmataCommand error:error];
        }
    }
}

- (void)didNotifyUpdate:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if([peripheral.identifier isEqual:_servicePeripheral.identifier])
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
}


@end

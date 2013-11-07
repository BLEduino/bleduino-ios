//
//  UARTServiceClass.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 9/24/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "UARTService.h"
#import "LeDiscoveryManager.h"

/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString *kUARTServiceUUIDString = @"8C6BDA7A-A312-681D-025B-0032C0D16A2D";
NSString *kRxCharacteristicUUIDString = @"8C6BABCD-A312-681D-025B0032C0D16A2D";
NSString *kTxCharacteristicUUIDString = @"8C6B1010-A312-681D-025B0032C0D16A2D";

@implementation UARTService
{
    @private    
    CBUUID              *_uartServiceUUID;
    CBUUID              *_rxCharacteristicUUID;
    CBUUID              *_txCharacteristicUUID;
    
    id <UARTServiceDelegate> _delegate;
    
    BOOL _longTransmission;
    BOOL _textTransmission;
    BOOL _textSubscription;
}

#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
               controller:(id<UARTServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = self;
		_delegate = aController;
        
        _uartServiceUUID = [CBUUID UUIDWithString:kUARTServiceUUIDString];
        _rxCharacteristicUUID = [CBUUID UUIDWithString:kRxCharacteristicUUIDString];
        _txCharacteristicUUID = [CBUUID UUIDWithString:kTxCharacteristicUUIDString];
    }
    
    return self;
}

#pragma mark -
#pragma mark Write Messages
/****************************************************************************/
/*				      Write messages/data to BLEduino                       */
/****************************************************************************/

- (void) writeData:(NSData *)data withAck:(BOOL)enabled
{
    int dataLength = (int)data.length;
    
    if(dataLength > 20)
    {
        BOOL lastPacket = false;
        int dataIndex = 0;
        int totalPackets = ceil(dataLength / 20);
        
        for (int packetIndex = 0; packetIndex <= totalPackets; packetIndex++)
        {
            lastPacket = (packetIndex == totalPackets);
            int rangeLength = (lastPacket)?(dataLength - dataIndex):20;
            
            NSRange dataRange = NSMakeRange(dataIndex, rangeLength);
            NSData *dataSubset = [data subdataWithRange:dataRange];
            _longTransmission = !lastPacket;
            

            [self writeDataToPeripheral:_servicePeripheral
                            serviceUUID:_uartServiceUUID
                     characteristicUUID:_rxCharacteristicUUID
                                   data:dataSubset
                                withAck:enabled];
            
            //Move dataIndex to the beginning of next packet.
            dataIndex += 20;
        }
    }
    else
    {
        [self writeDataToPeripheral:_servicePeripheral
                        serviceUUID:_uartServiceUUID
                 characteristicUUID:_rxCharacteristicUUID
                               data:data
                            withAck:enabled];
    }
}

- (void) writeData:(NSData *)data
{
    self.dataSent = data;
    [self writeData:data withAck:NO];
}

- (void) writeMessage:(NSString *)message withAck:(BOOL)enabled
{
    _textTransmission = YES;
    
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self writeData:messageData withAck:enabled];
}

- (void) writeMessage:(NSString *)message
{
    self.messageSent = message;
    [self writeMessage:message withAck:NO];
}


#pragma mark -
#pragma mark Read Messages
/****************************************************************************/
/*				      Read messages / data from BLEduino                    */
/****************************************************************************/

- (void) readData
{
    [self readDataFromPeripheral:_servicePeripheral
                     serviceUUID:_uartServiceUUID
              characteristicUUID:_txCharacteristicUUID];
}

- (void) readMessage
{
    _textTransmission = YES;
    [self readData];
}

- (void) subscribeToStartReceivingData
{
    [self setNotificationForPeripheral:_servicePeripheral
                           serviceUUID:_uartServiceUUID
                    characteristicUUID:_txCharacteristicUUID
                           notifyValue:YES];
}

- (void) unsubscribeToStopReiceivingData
{
    [self setNotificationForPeripheral:_servicePeripheral
                           serviceUUID:_uartServiceUUID
                    characteristicUUID:_txCharacteristicUUID
                           notifyValue:NO];
}

- (void) subscribeToStartReceivingMessages
{
    _textSubscription = YES;
    [self subscribeToStartReceivingData];
}

- (void) unsubscribeToStopReiceivingMessages
{
    _textSubscription = NO;
    [self unsubscribeToStopReiceivingData];
}

#pragma mark -
#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate     `                        */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(!_longTransmission)
    {
        if(_textTransmission)
        {
            _textTransmission = NO;
            self.messageSent = [NSString stringWithUTF8String:[characteristic.value bytes]];
        }
        else
        {
            self.dataSent = characteristic.value;
        }
        
        if([_delegate respondsToSelector:@selector(uartService:didWriteMessage:error:)])
        {
            [_delegate uartService:self didWriteMessage:self.messageSent error:error];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(!_longTransmission)
    {
        if(_textTransmission)
        {
            _textTransmission = NO;
            self.messageReceived = [NSString stringWithUTF8String:[characteristic.value bytes]];
        }
        else
        {
            self.dataReceived = characteristic.value;
        }
        
        if([_delegate respondsToSelector:@selector(uartService:didReceiveMessage:error:)])
        {
            [_delegate uartService:self didReceiveMessage:self.messageReceived error:error];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.isNotifying)
    {
        if(_textSubscription)
        {
            _textSubscription = NO;
            if([_delegate respondsToSelector:@selector(didSubscribeToReceiveMessagesFor:error:)])
            {
                [_delegate didSubscribeToReceiveMessagesFor:self error:error];
            }
        }
        else
        {
            if([_delegate respondsToSelector:@selector(didSubscribeToReceiveDataFor:error:)])
            {
                [_delegate didSubscribeToReceiveDataFor:self error:error];
            }
        }
    }
    else
    {
        if(_textSubscription)
        {
            _textSubscription = NO;
            if([_delegate respondsToSelector:@selector(didUnsubscribeToReceiveMessagesFor:error:)])
            {
                [_delegate didUnsubscribeToReceiveMessagesFor:self error:error];
            }
        }
        else
        {
            if([_delegate respondsToSelector:@selector(didSubscribeToReceiveDataFor:error:)])
            {
                [_delegate didSubscribeToReceiveDataFor:self error:error];
            }
        }
    }
}

@end

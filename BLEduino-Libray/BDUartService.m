//
//  UARTServiceClass.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 9/24/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDUartService.h"
#import "BDLeDiscoveryManager.h"

#pragma mark -
#pragma mark - UART Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString * const kUARTServiceUUIDString = @"8C6BDA7A-A312-681D-025B-0032C0D16A2D";
NSString * const kRxCharacteristicUUIDString = @"8C6BABCD-A312-681D-025B-0032C0D16A2D";
NSString * const kTxCharacteristicUUIDString = @"8C6B1010-A312-681D-025B-0032C0D16A2D";

@interface BDUartService ()

@property (strong) CBUUID *uartServiceUUID;
@property (strong) CBUUID *rxCharacteristicUUID;
@property (strong) CBUUID *txCharacteristicUUID;

@property BOOL longTransmission;
@property BOOL textTransmission;
@property BOOL textSubscription;

@property (weak) id <UARTServiceDelegate> delegate;

@end

#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*								Setup										*/
/****************************************************************************/
@implementation BDUartService

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<UARTServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = self;
		self.delegate = aController;
        
        self.uartServiceUUID = [CBUUID UUIDWithString:kUARTServiceUUIDString];
        self.rxCharacteristicUUID = [CBUUID UUIDWithString:kRxCharacteristicUUIDString];
        self.txCharacteristicUUID = [CBUUID UUIDWithString:kTxCharacteristicUUIDString];
    }
    
    return self;
}

#pragma mark -
#pragma mark - Write Messages
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
        int totalPackets = ceil(dataLength / 19);
        
        for (int packetIndex = 0; packetIndex <= totalPackets; packetIndex++)
        {
            
            lastPacket = (packetIndex == totalPackets);
            int rangeLength = (lastPacket)?(dataLength - dataIndex):19;
            
            NSRange dataRange = NSMakeRange(dataIndex, rangeLength);
            NSData *dataSubset = [data subdataWithRange:dataRange];
            self.longTransmission = !lastPacket;
            

            NSMutableData *finalData = [[NSMutableData alloc] initWithCapacity:[dataSubset length]+1];

            //Include state data.
            if (dataIndex == 0)
            {//Starting transmission.
                
                Byte startByte = (0 >> (0)) & 0xff;
                NSMutableData *startData = [NSMutableData dataWithBytes:&startByte length:sizeof(startByte)];
                [finalData appendData:startData];
            }
            else if(lastPacket)
            {//Ending transmission.
                
                Byte endByte = (2 >> (0)) & 0xff;
                NSMutableData *endData = [NSMutableData dataWithBytes:&endByte length:sizeof(endByte)];
                [finalData appendData:endData];
            }
            else if (dataIndex > 0)
            {//Transmission is in transit.
                
                Byte transitByte = (1 >> (0)) & 0xff;
                NSMutableData *transitData = [NSMutableData dataWithBytes:&transitByte length:sizeof(transitByte)];
                [finalData appendData:transitData];
            }
            
            //Append message data.
            [finalData appendData:dataSubset];
            
            [self writeDataToServiceUUID:self.uartServiceUUID
                      characteristicUUID:self.rxCharacteristicUUID
                                    data:finalData
                                 withAck:enabled];
            
            //Move dataIndex to the beginning of next packet.
            dataIndex += 19;
        }
    }
    else
    {
        [self writeDataToServiceUUID:self.uartServiceUUID
                  characteristicUUID:self.rxCharacteristicUUID
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
    self.textTransmission = YES;
    
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self writeData:messageData withAck:enabled];
}

- (void) writeMessage:(NSString *)message
{
    self.messageSent = message;
    [self writeMessage:message withAck:NO];
}


#pragma mark -
#pragma mark - Read Messages
/****************************************************************************/
/*				      Read messages / data from BLEduino                    */
/****************************************************************************/

- (void) readData
{
    [self readDataFromServiceUUID:self.uartServiceUUID
               characteristicUUID:self.txCharacteristicUUID];
}

- (void) readMessage
{
    self.textTransmission = YES;
    [self readData];
}

- (void) subscribeToStartReceivingData
{
    [self setNotificationForServiceUUID:self.uartServiceUUID
                     characteristicUUID:self.txCharacteristicUUID
                            notifyValue:YES];
}

- (void) unsubscribeToStopReiceivingData
{
    [self setNotificationForServiceUUID:self.uartServiceUUID
                     characteristicUUID:self.txCharacteristicUUID
                            notifyValue:NO];
}

- (void) subscribeToStartReceivingMessages
{
    self.textSubscription = YES;
    [self subscribeToStartReceivingData];
}

- (void) unsubscribeToStopReiceivingMessages
{
    self.textSubscription = NO;
    [self unsubscribeToStopReiceivingData];
}

#pragma mark -
#pragma mark - Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate     `                        */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(!self.longTransmission)
    {
        if(self.textTransmission)
        {
            self.textTransmission = NO;
            self.messageSent = [NSString stringWithUTF8String:[characteristic.value bytes]];
        }
        else
        {
            self.dataSent = characteristic.value;
        }
        
        if([self.delegate respondsToSelector:@selector(uartService:didWriteMessage:error:)])
        {
            [self.delegate uartService:self didWriteMessage:self.messageSent error:error];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(!self.longTransmission)
    {
        if(self.textTransmission)
        {
            self.textTransmission = NO;
            self.messageReceived = [NSString stringWithUTF8String:[characteristic.value bytes]];
        }
        else
        {
            self.dataReceived = characteristic.value;
        }
        
        if([self.delegate respondsToSelector:@selector(uartService:didReceiveMessage:error:)])
        {
            [self.delegate uartService:self didReceiveMessage:self.messageReceived error:error];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.isNotifying)
    {
        if(self.textSubscription)
        {
            self.textSubscription = NO;
            if([self.delegate respondsToSelector:@selector(didSubscribeToReceiveMessagesFor:error:)])
            {
                [self.delegate didSubscribeToReceiveMessagesFor:self error:error];
            }
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(didSubscribeToReceiveDataFor:error:)])
            {
                [self.delegate didSubscribeToReceiveDataFor:self error:error];
            }
        }
    }
    else
    {
        if(self.textSubscription)
        {
            self.textSubscription = NO;
            if([self.delegate respondsToSelector:@selector(didUnsubscribeToReceiveMessagesFor:error:)])
            {
                [self.delegate didUnsubscribeToReceiveMessagesFor:self error:error];
            }
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(didSubscribeToReceiveDataFor:error:)])
            {
                [self.delegate didSubscribeToReceiveDataFor:self error:error];
            }
        }
    }
}

@end

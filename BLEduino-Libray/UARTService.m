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
//NSString *kRxCharacteristicUUIDString = @"8C6BABCD-A312-681D-025B0032C0D16A2D";
NSString *kRxCharacteristicUUIDString = @"6e400002-b5a3-f393-e0a9-e50e24dcca9e";

//NSString *kTxCharacteristicUUIDString = @"8C6B1010-A312-681D-025B0032C0D16A2D";
NSString *kTxCharacteristicUUIDString = @"3355";


@interface UARTService() <CBPeripheralDelegate>
{
    @private
    CBPeripheral		*servicePeripheral;
    
    CBService			*uartService;
    CBCharacteristic    *rxCharacteristic;
    CBCharacteristic	*txCharacteristic;

    CBUUID              *uartServiceUUID;
    CBUUID              *rxCharacteristicUUID;
    CBUUID              *txCharacteristicUUID;
    
    id <UARTServiceDelegate> delegate;
    
    BOOL longTransmission;
    BOOL textTransmission;
    BOOL textSubscription;
}
@end


@implementation UARTService
@synthesize messageSent, messageReceived;
@synthesize peripheral = servicePeripheral;

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
        servicePeripheral = [aPeripheral copy];
        servicePeripheral.delegate = self;
		delegate = aController;
        
        uartServiceUUID = [CBUUID UUIDWithString:kUARTServiceUUIDString];
        rxCharacteristicUUID = [CBUUID UUIDWithString:kRxCharacteristicUUIDString];
        txCharacteristicUUID = [CBUUID UUIDWithString:kTxCharacteristicUUIDString];
    }
    
    return self;
}

- (id) uartServiceWithController:(id<UARTServiceDelegate>)aController
{
    //PENDING
    //selects peripheral automatically and abstracts the need to handle the peripheral completely.
    return nil;
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
            longTransmission = lastPacket;
            
            if(enabled)
            {
                [servicePeripheral writeValue:dataSubset forCharacteristic:rxCharacteristic type:CBCharacteristicWriteWithResponse];
            }
            else
            {
                [servicePeripheral writeValue:dataSubset forCharacteristic:rxCharacteristic type:CBCharacteristicWriteWithoutResponse];
            }
            
            //Move dataIndex to the start of next packet.
            dataIndex += 20;
        }
    }
    else
    {
        if(enabled)
        {
            [servicePeripheral writeValue:data forCharacteristic:rxCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        else
        {
            LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
            [servicePeripheral writeValue:data forCharacteristic:leManager.uartRXChar type:CBCharacteristicWriteWithoutResponse];
        }

    }
}

- (void) writeData:(NSData *)data
{
    [self writeData:data withAck:NO];
}

- (void) writeMessage:(NSString *)message withAck:(BOOL)enabled
{
    textTransmission = YES;
    
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
    [servicePeripheral readValueForCharacteristic:txCharacteristic];
}

- (void)readMessage
{
    textTransmission = YES;
    [self readData];
}

- (void) subscribeToStartReceivingData
{
    [servicePeripheral setNotifyValue:YES forCharacteristic:txCharacteristic];
}

- (void) unsubscribeToStopReiceivingData
{
    [servicePeripheral setNotifyValue:NO forCharacteristic:txCharacteristic];
}

- (void) subscribeToStartReceivingMessages
{
    textSubscription = YES;
    [self subscribeToStartReceivingData];
}

- (void) unsubscribeToStopReiceivingMessages
{
    textSubscription = NO;
    [self unsubscribeToStopReiceivingData];
}

- (void) dismissPeripheral
{
	if (servicePeripheral) {
		servicePeripheral = nil;
        servicePeripheral.delegate = nil;
	}
}

#pragma mark -
#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(!longTransmission)
    {
        [delegate uartService:self didWriteMessage:self.messageSent error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(!longTransmission)
    {
        [delegate uartService:self didReceiveMessage:self.messageReceived error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.isNotifying)
    {
        if(textSubscription)
        {
            [delegate didSubscribeToReceiveMessagesFor:self error:error];
            textSubscription = NO;
        }
        else
        {
            [delegate didSubscribeToReceiveDataFor:self error:error];
        }
    }
    else
    {
        if(textSubscription)
        {
            [delegate didUnsubscribeToReceiveMessagesFor:self error:error];
            textSubscription = NO;
        }
        else
        {
            [delegate didSubscribeToReceiveDataFor:self error:error];
        }
    }
}

@end

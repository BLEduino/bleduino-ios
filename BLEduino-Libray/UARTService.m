//
//  UARTServiceClass.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 9/24/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "UARTService.h"

/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString *kUARTServiceUUIDString = @"8C6BDA7A-A312-681D-025B-0032C0D16A2D";
NSString *kRxCharacteristicUUIDString = @"8C6BABCD-A312-681D-025B0032C0D16A2D";
NSString *kTxCharacteristicUUIDString = @"8C6B1010-A312-681D-025B0032C0D16A2D";

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
/*				      Write messages to BLEduino                            */
/****************************************************************************/
//
- (void) writeMessage:(NSString *)message withAck:(BOOL)enabled
{
    int dataLength = message.length;
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    
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
            NSData *data = [messageData subdataWithRange:dataRange];
            longTransmission = lastPacket;
            if(enabled)
            {
                [servicePeripheral writeValue:data forCharacteristic:rxCharacteristic type:CBCharacteristicWriteWithResponse];
            }
            else
            {
                [servicePeripheral writeValue:data forCharacteristic:rxCharacteristic type:CBCharacteristicWriteWithoutResponse];
            }
            
            //Move dataIndex to the start of next packet.
            dataIndex += 20;
        }
    }
    else
    {
        if(enabled)
        {
            [servicePeripheral writeValue:messageData forCharacteristic:rxCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        else
        {
            [servicePeripheral writeValue:messageData forCharacteristic:rxCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }

    }
}
- (void) writeMessage:(NSString *)message
{
    self.messageSent = message;
    
    [self writeMessage:message withAck:NO];
}


#pragma mark -
#pragma mark Read Messages
/****************************************************************************/
/*				      Read messages from BLEduino                           */
/****************************************************************************/
- (void) readMessage
{
    [servicePeripheral readValueForCharacteristic:txCharacteristic];
}
- (void) subscribeToStartReceivingMessages
{
    [servicePeripheral setNotifyValue:YES forCharacteristic:txCharacteristic];
}

- (void) unsubscribeToStopReiceivingMessages
{
    [servicePeripheral setNotifyValue:NO forCharacteristic:txCharacteristic];
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
    [delegate uartService:self didWriteMessage:self.messageSent error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [delegate uartService:self didReceiveMessage:self.messageReceived error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.isNotifying)
    {
        [delegate didSubscribeToReceiveMessagesFor:self];
    }
    else
    {
        [delegate didUnsubscribeToReceiveMessagesFor:self];
    }
}

@end

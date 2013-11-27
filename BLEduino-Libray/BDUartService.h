//
//  UARTServiceClass.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 9/24/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BDBleService.h"

#pragma mark -
#pragma mark UART Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString * const kUARTServiceUUIDString;            //8C6BDA7A-A312-681D-025B-0032C0D16A2D  UART Service
extern NSString * const kRxCharacteristicUUIDString;       //8C6BABCD-A312-681D-025B-0032C0D16A2D  Read(Rx) Message Characteristic
extern NSString * const kTxCharacteristicUUIDString;       //8C6B1010-A312-681D-025B-0032C0D16A2D  Write(Tx) Message Characteristic


/****************************************************************************/
/*						Rx/Tx Transmission State							*/
/****************************************************************************/
enum {
    RxTxTransmissionStateStarted = 0,
    RxTxTransmissionStateInTransit = 1,
    RxTxTransmissionStateEnded = 2,
};
typedef NSUInteger RxTxTransmissionState;


#pragma mark -
#pragma mark UART Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BDUartService;
@protocol UARTServiceDelegate <NSObject>
@optional
- (void)uartService:(BDUartService *)service didReceiveData:(NSData *)data error:(NSError *)error;
- (void)uartService:(BDUartService *)service didReceiveMessage:(NSString *)message error:(NSError *)error;

- (void)uartService:(BDUartService *)service didWriteData:(NSData *)data error:(NSError *)error;
- (void)uartService:(BDUartService *)service didWriteMessage:(NSString *)message error:(NSError *)error;

- (void)didSubscribeToReceiveDataFor:(BDUartService *)service error:(NSError *)error;
- (void)didUnsubscribeToReceiveDataFor:(BDUartService *)service error:(NSError *)error;

- (void)didSubscribeToReceiveMessagesFor:(BDUartService *)service error:(NSError *)error;
- (void)didUnsubscribeToReceiveMessagesFor:(BDUartService *)service error:(NSError *)error;
@end


/****************************************************************************/
/*						 UART Service                                       */
/****************************************************************************/
@interface BDUartService : BDBleService <CBPeripheralDelegate>

@property (strong) NSString *messageSent;
@property (strong) NSString *messageReceived;

@property (strong) NSData *dataSent;
@property (strong) NSData *dataReceived;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<UARTServiceDelegate>)aController;

#pragma mark -
#pragma mark Writing to BLEduino
// Writing messages to BLEduino.
- (void) writeMessage:(NSString *)message withAck:(BOOL)enabled;
- (void) writeMessage:(NSString *)message;

// Writing data to BLEduino.
- (void) writeData:(NSData *)data withAck:(BOOL)enabled;
- (void) writeData:(NSData *)data;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving messages from BLEduino.
- (void) readMessage;
- (void) subscribeToStartReceivingMessages;
- (void) unsubscribeToStopReiceivingMessages;

// Read/Receiving data from BLEduino.
- (void) readData;
- (void) subscribeToStartReceivingData;
- (void) unsubscribeToStopReiceivingData;

@end

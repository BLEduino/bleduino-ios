//
//  UARTServiceClass.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 9/24/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleService.h"

/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString *kUARTServiceUUIDString;            //8C6BDA7A-A312-681D-025B-0032C0D16A2D  UART Service
extern NSString *kRxCharacteristicUUIDString;       //8C6BABCD-A312-681D-025B-0032C0D16A2D  Read(Rx) Message Characteristic
extern NSString *kTxCharacteristicUUIDString;       //8C6B1010-A312-681D-025B-0032C0D16A2D  Write(Tx) Message Characteristic


#pragma mark -
#pragma mark UART Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class UARTService;
@protocol UARTServiceDelegate <NSObject>
@optional
- (void)uartService:(UARTService *)service didReceiveData:(NSData *)data error:(NSError *)error;
- (void)uartService:(UARTService *)service didReceiveMessage:(NSString *)message error:(NSError *)error;

- (void)uartService:(UARTService *)service didWriteData:(NSData *)data error:(NSError *)error;
- (void)uartService:(UARTService *)service didWriteMessage:(NSString *)message error:(NSError *)error;

- (void)didSubscribeToReceiveDataFor:(UARTService *)service error:(NSError *)error;
- (void)didUnsubscribeToReceiveDataFor:(UARTService *)service error:(NSError *)error;

- (void)didSubscribeToReceiveMessagesFor:(UARTService *)service error:(NSError *)error;;
- (void)didUnsubscribeToReceiveMessagesFor:(UARTService *)service error:(NSError *)error;;
@end


/****************************************************************************/
/*						UART service.                                       */
/****************************************************************************/
@interface UARTService : BleService <CBPeripheralDelegate>

@property (nonatomic, strong) NSString *messageSent;
@property (nonatomic, strong) NSString *messageReceived;

@property (nonatomic, strong) NSString *dataSent;
@property (nonatomic, strong) NSString *dataReceived;

@property (readonly) CBPeripheral *peripheral;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral controller:(id<UARTServiceDelegate>)aController;
- (void) dismissPeripheral;

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

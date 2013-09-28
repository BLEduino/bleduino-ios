//
//  UARTServiceClass.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 9/24/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString *kUARTServiceUUIDString;            //8C6B-DA7A-A312-681D-025B-0032-C0D1-6A2D  UART Service
extern NSString *kRxCharacteristicUUIDString;       //8C6B-ABCD-A312-681D-025B-0032-C0D1-6A2D  Read(Rx) Message Characteristic
extern NSString *kTxCharacteristicUUIDString;       //8C6B-1010-A312-681D-025B-0032-C0D1-6A2D  Write(Tx) Message Characteristic


/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class UARTService;
@protocol UARTServiceDelegate <NSObject>
@required
- (void)uartService:(UARTService *)service didReceiveMessage:(NSString *)message;

@optional
- (void)uartService:(UARTService *)service didWriteMessage:(NSString *)message;
- (void)didSubscribeToReceiveMessagesFor:(UARTService *)service;
- (void)didUnsubscribeToReceiveMessagesFor:(UARTService *)service;
@end


/****************************************************************************/
/*						UART service.                                       */
/****************************************************************************/
@interface UARTService : NSObject <CBPeripheralDelegate>

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<UARTServiceDelegate>)controller;

// Writing messages to BLEduino.
- (void) writeMessage:(NSString *)message withAck:(BOOL)enabled;
- (void) writeMessage:(NSString *)message;

// Read/Receiving messages from BLEduino.
- (void) readMessage;
- (void) subscribeToReceiveMessagesWithAck:(BOOL)enabled;
- (void) subscribeToReceiveMessages;
- (void) unsubscribeToReceiveMessagesWithAck:(BOOL)enabled;
- (void) unsubscribeToReiceiveMessages;

@property (nonatomic, strong) NSMutableString *sentMessage;
@property (nonatomic, strong) NSMutableString *receivedMessage;
@property (readonly) CBPeripheral *peripheral;
@end

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
extern NSString *kUARTServiceUUIDString;            //8C6BDA7A-A312-681D-025B-0032C0D16A2D  UART Service
extern NSString *kRxCharacteristicUUIDString;       //8C6BABCD-A312-681D-025B-0032C0D16A2D  Read(Rx) Message Characteristic
extern NSString *kTxCharacteristicUUIDString;       //8C6B1010-A312-681D-025B-0032C0D16A2D  Write(Tx) Message Characteristic


/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class UARTService;
@protocol UARTServiceDelegate <NSObject>
@required
- (void)uartService:(UARTService *)service didReceiveMessage:(NSString *)message error:(NSError *)error;

@optional
- (void)uartService:(UARTService *)service didWriteMessage:(NSString *)message error:(NSError *)error;
- (void)didSubscribeToReceiveMessagesFor:(UARTService *)service;
- (void)didUnsubscribeToReceiveMessagesFor:(UARTService *)service;
@end


/****************************************************************************/
/*						UART service.                                       */
/****************************************************************************/
@interface UARTService : NSObject <CBPeripheralDelegate>

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral controller:(id<UARTServiceDelegate>)aController;
- (void) dismissPeripheral;

// Writing messages to BLEduino.
- (void) writeMessage:(NSString *)message withAck:(BOOL)enabled;
- (void) writeMessage:(NSString *)message;

// Read/Receiving messages from BLEduino.
- (void) readMessage;
- (void) subscribeToStartReceivingMessages;
- (void) unsubscribeToStopReiceivingMessages;

@property (nonatomic, strong) NSString *messageSent;
@property (nonatomic, strong) NSString *messageReceived;
@property (readonly) CBPeripheral *peripheral;
@end

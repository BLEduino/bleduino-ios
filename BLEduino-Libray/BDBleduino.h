//
//  BDWrite.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/7/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BDFirmata.h"
#import "BDController.h"
#import "BDVehicleMotion.h"
#import "BDUart.h"
#import "BDBridge.h"
#import "BDNotification.h"

enum BlePipe {
    Firmata = 0,
    UART = 1,
    Controller = 2,
    VehicleMotion = 3
};
typedef NSUInteger BlePipe;

#pragma mark -
#pragma mark BDBLeduino Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BDBleduino;
@protocol BleduinoDelegate <NSObject>
@required
- (void) bleduino:(CBPeripheral *)bleduino
    didUpdateValue:(id)data
             pipe:(BlePipe)pipe
            error:(NSError *)error;

- (void) bleduino:(CBPeripheral *)bleduino
     didWriteValue:(id)data
             pipe:(BlePipe)pipe
            error:(NSError *)error;

- (void)  bleduino:(CBPeripheral *)bleduino
      didSubscribe:(BlePipe)pipe
            notify:(BOOL)notify
             error:(NSError *)error;

@optional
- (void) bleduino:(CBPeripheral *)bleduino
   didFailToWrite:(id)data;

@end

/****************************************************************************/
/*						 BLEduino Service                                   */
/****************************************************************************/
@interface BDBleduino : NSObject
<
FirmataServiceDelegate,
ControllerServiceDelegate,
VehicleMotionServiceDelegate,
UARTServiceDelegate,
BleBridgeServiceDelegate,
NotificationServiceDelegate
>

@property (readonly, strong) CBPeripheral *bleduino;


+ (instancetype)bleduino:(CBPeripheral *)bleduino
                delegate:(id<BleduinoDelegate>)delegate;

/*
 * The following methods allows developer to write/read/subscribe to:
 * Firmata, Controller, Vehicle Motion, and UART.
 */
+ (void) writeValue:(id)data;

+ (void) writeValue:(id)data bleduino:(CBPeripheral *)bleduino;

- (void) writeValue:(id)data withAck:(BOOL)enabled;

- (void) writeValue:(id)data;

- (void) readValue:(BlePipe)pipe;

- (void) subscribe:(BlePipe)pipe
            notify:(BOOL)notify;

/*
 * The following methods allows developer to create/destory a BLE bridge, which allows
 * in turn (connected) BLEduinos to communicate with each other via the iOS device.
 */
//+ (void) openBridgeWithDelegate:(id<BleduinoDelegate>)delegate;
- (void) openBridge;
- (void) closeBridge;

/*
 * The following methods allows developer to create/destory a notifications listener,
 * which listens for notifications from any (connected) BLEduino.
 */
//+ (void) openBridgeWithDelegate:(id<BleduinoDelegate>)delegate;
- (void) startListening;
- (void) stopListening;


+ (void) updateBleduinoName:(CBPeripheral *)bleduino
                       name:(NSString *)name;

@end

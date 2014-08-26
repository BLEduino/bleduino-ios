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
#import "BDProximity.h"

enum BlePipe {
    Firmata = 0,
    UART = 1,
    Controller = 2,
    VehicleMotion = 3,
    Bridge = 4,
    Notification = 5
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
UARTServiceDelegate
>

@property (readonly, strong) CBPeripheral *bleduino;


+ (instancetype)bleduino:(CBPeripheral *)bleduino
                delegate:(id<BleduinoDelegate>)delegate;

/*
 * The following methods allows developer to write/read/subscribe to:
 * Firmata, Controller, Vehicle Motion, and UART.
 */

#pragma mark -
#pragma mark Writing to BLEduino
// Writing data to BLEduino.
+ (void) writeValue:(id)data;

+ (void) writeValue:(id)data bleduino:(CBPeripheral *)bleduino;

- (void) writeValue:(id)data withAck:(BOOL)enabled;

- (void) writeValue:(id)data;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receive data from BLEduino.
- (void) readValue:(BlePipe)pipe;

- (void) subscribe:(BlePipe)pipe
            notify:(BOOL)notify;

#pragma mark -
#pragma mark Configure BLEduino
//Configure the BLEduino
+ (void) updateBleduinoName:(CBPeripheral *)bleduino
                       name:(NSString *)name;

@end

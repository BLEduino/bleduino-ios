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
@optional

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void) bleduino:(CBPeripheral *)bleduino
    didWriteValue:(id)data
             pipe:(BlePipe)pipe
            error:(NSError *)error;

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void) bleduino:(CBPeripheral *)bleduino
   didUpdateValue:(id)data
             pipe:(BlePipe)pipe
            error:(NSError *)error;

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void)  bleduino:(CBPeripheral *)bleduino
      didSubscribe:(BlePipe)pipe
            notify:(BOOL)notify
             error:(NSError *)error;

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void)bleduino:(CBPeripheral *)bleduino
didUpdateValueForRange:(DistanceRange)range
     maxDistance:(NSNumber *)max
     minDistance:(NSNumber *)min
        withRSSI:(NSNumber *)RSSI;

@optional

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void) bleduino:(CBPeripheral *)bleduino
   didFailToWrite:(id)data;

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void)bleduino:(CBPeripheral *)bleduino didFinishCalibration:(NSNumber *)measuredPower;
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
ProximityDelegate
>

@property (readonly, strong) CBPeripheral *bleduino;

//Proximity
@property (strong) NSNumber *measuredPower; //Calibrated RSSI.
@property (getter=readImmediateRSSI, setter=writeImmediateRSSI:) float immediateRSSI;
@property (getter=readNearRSSI, setter=writeNearRSSI:) float nearRSSI;
@property (getter=readFarRSSI, setter=writeFarRSSI:) float farRSSI;
@property (getter=readPathLoss) float pathLoss; //Path Loss Exponent.


/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
+ (instancetype)bleduino:(CBPeripheral *)bleduino
                delegate:(id<BleduinoDelegate>)delegate;

/*
 * The following methods allows developer to write/read/subscribe to:
 * Firmata, Controller, Vehicle Motion, and UART.
 */

#pragma mark -
#pragma mark Writing to BLEduino
// Writing data to BLEduino.

/*
 *  @method                 writeValue:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
+ (void) writeValue:(id)data;

/*
 *  @method                 writeValue:bleduino:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
+ (void) writeValue:(id)data bleduino:(CBPeripheral *)bleduino;

/*
 *  @method                 writeValue:withAck:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
- (void) writeValue:(id)data withAck:(BOOL)enabled;

/*
 *  @method                 writeValue:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
- (void) writeValue:(id)data;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receive data from BLEduino.

/*
 *  @method                 readValue:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
- (void) readValue:(BlePipe)pipe;


/*
 *  @method                 subscribe:notify:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
- (void) subscribe:(BlePipe)pipe
            notify:(BOOL)notify;

#pragma mark -
#pragma mark Proximity
//Proximity

/*
 *  @method                 startMonitoringProximity
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
- (void) startMonitoringProximity;

/*
 *  @method                 stopMonitoringProximity
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
- (void) stopMonitoringProximity;

/*
 *  @method                 startProximityCalibration
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
- (void) startProximityCalibration;

#pragma mark -
#pragma mark Configure BLEduino
//Configure the BLEduino

/*
 *  @method                 updateBleduinoName:name:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
+ (void) updateBleduinoName:(CBPeripheral *)bleduino
                       name:(NSString *)name;

@end

//
//  VehicleMotionService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "BleService.h"
#import "ThrottleYawRollPitchCharacteristic.h"

#pragma mark -
#pragma mark Vehicle Motion Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString *kVehicleMotionServiceUUIDString;
//8C6B1125-A312-681D-025B-0032C0D16A2D  VehicleMotion Service

extern NSString *kThrottleYawRollPitchCharacteristicUUIDString;
//8C6B9806-A312-681D-025B-0032C0D16A2D  Throttle-Yaw-Roll-Pitch Characteristic


#pragma mark -
#pragma mark Vehicle Motion Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class VehicleMotionService;
@protocol VehicleMotionServiceDelegate <NSObject>
@optional
- (void)vehicleMotionService:(VehicleMotionService *)service
            didReceiveMotion:(ThrottleYawRollPitchCharacteristic *)motionUpdate
                       error:(NSError *)error;

- (void)vehicleMotionService:(VehicleMotionService *)service
              didWriteMotion:(ThrottleYawRollPitchCharacteristic *)motionUpdate
                       error:(NSError *)error;

- (void)didSubscribeToStartReceivingMotionUpdatesFor:(VehicleMotionService *)service error:(NSError *)error;
- (void)didUnsubscribeToStopRecivingMotionUpdatesFor:(VehicleMotionService *)service error:(NSError *)error;
@end

/****************************************************************************/
/*                      Vehicle Motion Service                              */
/****************************************************************************/
@interface VehicleMotionService : BleService <CBPeripheralDelegate>
@property (nonatomic, strong) ThrottleYawRollPitchCharacteristic *lastMotionUpdate;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral controller:(id<VehicleMotionServiceDelegate>)aController;

#pragma mark -
#pragma mark Writing to BLEduino
// Write motion update to BLEduino.
- (void) writeMotionUpdate:(ThrottleYawRollPitchCharacteristic *)motion withAck:(BOOL)enabled;
- (void) writeMotionUpdate:(ThrottleYawRollPitchCharacteristic *)motion;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving motion update from BLEduino.
- (void) readMotionUpdate;
- (void) subscribeToStartReceivingMotionUpdates;
- (void) unsubscribeToStopReiceivingMotionUpdates;


@end



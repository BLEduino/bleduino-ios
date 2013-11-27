//
//  VehicleMotionService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "BDBleService.h"
#import "BDThrottleYawRollPitchCharacteristic.h"

#pragma mark -
#pragma mark Vehicle Motion Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString * const kVehicleMotionServiceUUIDString;
//8C6B1125-A312-681D-025B-0032C0D16A2D  VehicleMotion Service

extern NSString * const kThrottleYawRollPitchCharacteristicUUIDString;
//8C6B9806-A312-681D-025B-0032C0D16A2D  Throttle-Yaw-Roll-Pitch Characteristic


#pragma mark -
#pragma mark Vehicle Motion Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BDVehicleMotionService;
@protocol VehicleMotionServiceDelegate <NSObject>
@optional
- (void)vehicleMotionService:(BDVehicleMotionService *)service
            didReceiveMotion:(BDThrottleYawRollPitchCharacteristic *)motionUpdate
                       error:(NSError *)error;

- (void)vehicleMotionService:(BDVehicleMotionService *)service
              didWriteMotion:(BDThrottleYawRollPitchCharacteristic *)motionUpdate
                       error:(NSError *)error;

- (void)didSubscribeToStartReceivingMotionUpdatesFor:(BDVehicleMotionService *)service error:(NSError *)error;
- (void)didUnsubscribeToStopRecivingMotionUpdatesFor:(BDVehicleMotionService *)service error:(NSError *)error;
@end

/****************************************************************************/
/*                      Vehicle Motion Service                              */
/****************************************************************************/
@interface BDVehicleMotionService : BDBleService <CBPeripheralDelegate>
@property (nonatomic, strong) BDThrottleYawRollPitchCharacteristic *lastMotionUpdate;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<VehicleMotionServiceDelegate>)aController;

#pragma mark -
#pragma mark Writing to BLEduino
// Write motion update to BLEduino.
- (void) writeMotionUpdate:(BDThrottleYawRollPitchCharacteristic *)motion withAck:(BOOL)enabled;
- (void) writeMotionUpdate:(BDThrottleYawRollPitchCharacteristic *)motion;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving motion update from BLEduino.
- (void) readMotionUpdate;
- (void) subscribeToStartReceivingMotionUpdates;
- (void) unsubscribeToStopReiceivingMotionUpdates;


@end



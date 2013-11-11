//
//  VehicleMotionService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "VehicleMotionService.h"

#pragma mark -
#pragma mark - Vehicle Motion Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString *kVehicleMotionServiceUUIDString = @"8C6B1125-A312-681D-025B-0032C0D16A2D";
NSString *kThrottleYawRollPitchCharacteristicUUIDString = @"8C6B9806-A312-681D-025B-0032C0D16A2D";

#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*								Setup										*/
/****************************************************************************/
@implementation VehicleMotionService
{
    @private    
    CBUUID              *_vehicleMotionServiceUUID;
    CBUUID              *_throttleYawRollPitchCharacteristicUUID;
    
    id <VehicleMotionServiceDelegate> _delegate;
    
    ThrottleYawRollPitchCharacteristic *_lastMotion;
}

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral controller:(id<VehicleMotionServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = self;
		_delegate = aController;
        
        _vehicleMotionServiceUUID = [CBUUID UUIDWithString:kVehicleMotionServiceUUIDString];
        _throttleYawRollPitchCharacteristicUUID = [CBUUID UUIDWithString:kThrottleYawRollPitchCharacteristicUUIDString];
    }
    
    return self;
}

#pragma mark -
#pragma mark Writing to BLEduino
/****************************************************************************/
/*				      Write motion update to BLEduino                       */
/****************************************************************************/
- (void) writeMotionUpdate:(ThrottleYawRollPitchCharacteristic *)motion
                   withAck:(BOOL)enabled
{
    _lastMotion = motion;
    [self writeDataToPeripheral:_servicePeripheral
                    serviceUUID:_vehicleMotionServiceUUID
             characteristicUUID:_throttleYawRollPitchCharacteristicUUID
                           data:[motion data]
                        withAck:enabled];
}

- (void) writeMotionUpdate:(ThrottleYawRollPitchCharacteristic *)motion
{
    self.lastMotionUpdate = motion;
    [self writeMotionUpdate:motion withAck:NO];
}

#pragma mark -
#pragma mark Reading from BLEduino
/****************************************************************************/
/*				      Read motion update from BLEduino                      */
/****************************************************************************/
- (void) readMotionUpdate
{
    [self readDataFromPeripheral:_servicePeripheral
                     serviceUUID:_vehicleMotionServiceUUID
              characteristicUUID:_throttleYawRollPitchCharacteristicUUID];
}

- (void) subscribeToStartReceivingMotionUpdates
{
    [self setNotificationForPeripheral:_servicePeripheral
                           serviceUUID:_vehicleMotionServiceUUID
                    characteristicUUID:_throttleYawRollPitchCharacteristicUUID
                           notifyValue:YES];
}

- (void) unsubscribeToStopReiceivingMotionUpdates
{
    [self setNotificationForPeripheral:_servicePeripheral
                           serviceUUID:_vehicleMotionServiceUUID
                    characteristicUUID:_throttleYawRollPitchCharacteristicUUID
                           notifyValue:NO];
}

#pragma mark -
#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastMotionUpdate = _lastMotion;
    if([_delegate respondsToSelector:@selector(vehicleMotionService:didWriteMotion:error:)])
    {
        [_delegate vehicleMotionService:self
                         didWriteMotion:self.lastMotionUpdate
                                  error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastMotionUpdate = [[ThrottleYawRollPitchCharacteristic alloc] initWithData:characteristic.value];
    if([_delegate respondsToSelector:@selector(vehicleMotionService:didReceiveMotion:error:)])
    {
        [_delegate vehicleMotionService:self
                       didReceiveMotion:self.lastMotionUpdate
                                  error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.isNotifying)
    {
        if([_delegate respondsToSelector:@selector(didSubscribeToStartReceivingMotionUpdatesFor:error:)])
        {
            [_delegate didSubscribeToStartReceivingMotionUpdatesFor:self error:error];
        }
    }
    else
    {
        if([_delegate respondsToSelector:@selector(didUnsubscribeToStopRecivingMotionUpdatesFor:error:)])
        {
            [_delegate didUnsubscribeToStopRecivingMotionUpdatesFor:self error:error];
        }
    }
}


@end

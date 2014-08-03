//
//  VehicleMotionService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDVehicleMotionService.h"

#pragma mark -
#pragma mark - Vehicle Motion Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString * const kVehicleMotionServiceUUIDString = @"8C6B1125-A312-681D-025B-0032C0D16A2D";
NSString * const kThrottleYawRollPitchCharacteristicUUIDString = @"8C6B9806-A312-681D-025B-0032C0D16A2D";

#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*								Setup										*/
/****************************************************************************/
@interface BDVehicleMotionService ()

@property (strong) CBUUID *vehicleMotionServiceUUID;
@property (strong) CBUUID *throttleYawRollPitchCharacteristicUUID;

@property (weak) id <VehicleMotionServiceDelegate> delegate;
@property (strong) BDThrottleYawRollPitchCharacteristic *lastMotion;
@end

@implementation BDVehicleMotionService

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<VehicleMotionServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = self;
		self.delegate = aController;
        
        self.vehicleMotionServiceUUID = [CBUUID UUIDWithString:kVehicleMotionServiceUUIDString];
        self.throttleYawRollPitchCharacteristicUUID = [CBUUID UUIDWithString:kThrottleYawRollPitchCharacteristicUUIDString];
    }
    
    return self;
}

#pragma mark -
#pragma mark Writing to BLEduino
/****************************************************************************/
/*				      Write motion update to BLEduino                       */
/****************************************************************************/
- (void) writeMotionUpdate:(BDThrottleYawRollPitchCharacteristic *)motion
                   withAck:(BOOL)enabled
{
    //Write only once every 100ms at the most.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastSent = [defaults objectForKey:LAST_SENT_TIMESTAMP];
    double timeCap = [defaults doubleForKey:WRITE_TIME_CAP];
    
    double timePassed_ms = [lastSent timeIntervalSinceNow] * -1000;
    if(timePassed_ms >= timeCap || lastSent == nil)
    {
        self.lastMotion = motion;
        [self writeDataToServiceUUID:self.vehicleMotionServiceUUID
                  characteristicUUID:self.throttleYawRollPitchCharacteristicUUID
                                data:[motion data]
                             withAck:enabled];
        
        [defaults setObject:[NSDate date] forKey:LAST_SENT_TIMESTAMP];
        [defaults synchronize];
    }
}

- (void) writeMotionUpdate:(BDThrottleYawRollPitchCharacteristic *)motion
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
    //Read only once every 100ms at the most.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastSent = [defaults objectForKey:LAST_SENT_TIMESTAMP];
    double timeCap = [defaults doubleForKey:WRITE_TIME_CAP];
    
    double timePassed_ms = [lastSent timeIntervalSinceNow] * -1000;
    if(timePassed_ms >= timeCap || lastSent == nil)
    {
        [self readDataFromServiceUUID:self.vehicleMotionServiceUUID
                   characteristicUUID:self.throttleYawRollPitchCharacteristicUUID];
        
        [defaults setObject:[NSDate date] forKey:LAST_SENT_TIMESTAMP];
        [defaults synchronize];
    }
}

- (void) subscribeToStartReceivingMotionUpdates
{
    [self setNotificationForServiceUUID:self.vehicleMotionServiceUUID
                     characteristicUUID:self.throttleYawRollPitchCharacteristicUUID
                            notifyValue:YES];
}

- (void) unsubscribeToStopReiceivingMotionUpdates
{
    [self setNotificationForServiceUUID:self.vehicleMotionServiceUUID
                     characteristicUUID:self.throttleYawRollPitchCharacteristicUUID
                            notifyValue:NO];
}

#pragma mark -
#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastMotionUpdate = self.lastMotion;
    if([self.delegate respondsToSelector:@selector(vehicleMotionService:didWriteMotion:error:)])
    {
        [self.delegate vehicleMotionService:self
                             didWriteMotion:self.lastMotionUpdate
                                      error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastMotionUpdate = [[BDThrottleYawRollPitchCharacteristic alloc] initWithData:characteristic.value];
    if([self.delegate respondsToSelector:@selector(vehicleMotionService:didReceiveMotion:error:)])
    {
        [self.delegate vehicleMotionService:self
                           didReceiveMotion:self.lastMotionUpdate
                                      error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.isNotifying)
    {
        if([self.delegate respondsToSelector:@selector(didSubscribeToStartReceivingMotionUpdatesFor:error:)])
        {
            [self.delegate didSubscribeToStartReceivingMotionUpdatesFor:self error:error];
        }
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(didUnsubscribeToStopRecivingMotionUpdatesFor:error:)])
        {
            [self.delegate didUnsubscribeToStopRecivingMotionUpdatesFor:self error:error];
        }
    }
}


@end

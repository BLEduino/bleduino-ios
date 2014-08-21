//
//  VehicleMotionService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDVehicleMotion.h"

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
@interface BDVehicleMotion ()

@property (strong) CBUUID *vehicleMotionServiceUUID;
@property (strong) CBUUID *throttleYawRollPitchCharacteristicUUID;

@property (weak) id <VehicleMotionServiceDelegate> delegate;
@property (strong) BDThrottleYawRollPitch *lastMotion;
@end

@implementation BDVehicleMotion

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
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didWriteValue:) name:CHARACTERISTIC_WRITE_ACK_VEHICLE_MOTION object:nil];
        [center addObserver:self selector:@selector(didUpdateValue:) name:CHARACTERISTIC_UPDATE_VEHICLE_MOTION object:nil];
        [center addObserver:self selector:@selector(didNotifyUpdate:) name:CHARACTERISTIC_NOTIFY_VEHICLE_MOTION object:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark Writing to BLEduino
/****************************************************************************/
/*				      Write motion update to BLEduino                       */
/****************************************************************************/
- (void) writeMotionUpdate:(BDThrottleYawRollPitch *)motion
                   withAck:(BOOL)enabled
{
    self.lastMotion = motion;
    [self writeDataToServiceUUID:self.vehicleMotionServiceUUID
              characteristicUUID:self.throttleYawRollPitchCharacteristicUUID
                            data:[motion data]
                         withAck:enabled];
}

- (void) writeMotionUpdate:(BDThrottleYawRollPitch *)motion
{
    [self writeMotionUpdate:motion withAck:NO];
}

#pragma mark -
#pragma mark Reading from BLEduino
/****************************************************************************/
/*				      Read motion update from BLEduino                      */
/****************************************************************************/
- (void) readMotionUpdate
{
    [self readDataFromServiceUUID:self.vehicleMotionServiceUUID
               characteristicUUID:self.throttleYawRollPitchCharacteristicUUID];
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
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kThrottleYawRollPitchCharacteristicUUIDString]])
    {
        self.lastMotionUpdate = self.lastMotion;
        if([self.delegate respondsToSelector:@selector(vehicleMotionService:didWriteMotion:error:)])
        {
            [self.delegate vehicleMotionService:self
                                 didWriteMotion:self.lastMotionUpdate
                                          error:error];
        }
    }
    else
    {
        [BDBleService peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kThrottleYawRollPitchCharacteristicUUIDString]])
    {
        self.lastMotionUpdate = [[BDThrottleYawRollPitch alloc] initWithData:characteristic.value];
        if([self.delegate respondsToSelector:@selector(vehicleMotionService:didReceiveMotion:error:)])
        {
            [self.delegate vehicleMotionService:self
                               didReceiveMotion:self.lastMotionUpdate
                                          error:error];
        }
    }
    else
    {
        [BDBleService peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kThrottleYawRollPitchCharacteristicUUIDString]])
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
    else
    {
        [BDBleService peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
}

#pragma mark -
#pragma mark - Peripheral Delegate Gateways
/****************************************************************************/
/*				       Peripheral Delegate Gateways                         */
/****************************************************************************/
- (void)didWriteValue:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if([peripheral.identifier isEqual:_servicePeripheral.identifier])
    {
        self.lastMotionUpdate = self.lastMotion;
        if([self.delegate respondsToSelector:@selector(vehicleMotionService:didWriteMotion:error:)])
        {
            [self.delegate vehicleMotionService:self
                                 didWriteMotion:self.lastMotionUpdate
                                          error:error];
        }
    }
}

- (void)didUpdateValue:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if([peripheral.identifier isEqual:_servicePeripheral.identifier])
    {
        self.lastMotionUpdate = [[BDThrottleYawRollPitch alloc] initWithData:characteristic.value];
        if([self.delegate respondsToSelector:@selector(vehicleMotionService:didReceiveMotion:error:)])
        {
            [self.delegate vehicleMotionService:self
                               didReceiveMotion:self.lastMotionUpdate
                                          error:error];
        }
    }
}

- (void)didNotifyUpdate:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if([peripheral.identifier isEqual:_servicePeripheral.identifier])
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
}

@end

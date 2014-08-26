//
//  NotificationService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDNotification.h"
#import "BDLeManager.h"

#pragma mark -
#pragma mark Notification Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString * const kNotificationServiceUUIDString = @"8C6B3141-A312-681D-025B-0032C0D16A2D";
NSString * const kNotificationAttributesCharacteristicUUIDString = @"8C6B1618-A312-681D-025B-0032C0D16A2D";


#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*								Setup										*/
/****************************************************************************/
@interface BDNotification ()

@property (strong) CBUUID *notificationServiceUUID;
@property (strong) CBUUID *notificationAttributesCharacteristicUUID;

@property (weak) id <NotificationServiceDelegate> delegate;
@property (strong) BDNotificationAttributes *lastSentNotification;
@end

@implementation BDNotification

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<NotificationServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
		self.delegate = aController;
        
        //Should this object be the peripheral's delagate, or are we using the global delegate?
        BDLeManager *manager = [BDLeManager sharedLeManager];
        if(!manager.isOnlyBleduinoDelegate) _servicePeripheral.delegate = self;
        
        self.notificationServiceUUID = [CBUUID UUIDWithString:kNotificationServiceUUIDString];
        self.notificationAttributesCharacteristicUUID = [CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString];
        
    }
    
    return self;
}

#pragma mark -
#pragma mark Writing to BLEduino
/****************************************************************************/
/*				       Write notification to BLEduino                       */
/****************************************************************************/
- (void) writeNotification:(BDNotificationAttributes *)notification
                   withAck:(BOOL)enabled
{
    self.lastSentNotification = notification;
    [self writeDataToServiceUUID:self.notificationServiceUUID
              characteristicUUID:self.notificationAttributesCharacteristicUUID
                            data:[notification data]
                         withAck:enabled];
}

- (void) writeNotification:(BDNotificationAttributes *)notification
{
    self.lastNotification = notification;
    [self writeNotification:notification withAck:NO];
}


#pragma mark -
#pragma mark Reading from BLEduino
/****************************************************************************/
/*				  Read/Recive notifications from BLEduino                   */
/****************************************************************************/
- (void) readNotification
{
    [self readDataFromServiceUUID:self.notificationServiceUUID
               characteristicUUID:self.notificationAttributesCharacteristicUUID];
}

- (void) subscribeToStartReceivingNotifications
{
    [self setNotificationForServiceUUID:self.notificationServiceUUID
                     characteristicUUID:self.notificationAttributesCharacteristicUUID
                            notifyValue:YES];
}

- (void) unsubscribeToStopReiceivingNotifications
{
    [self setNotificationForServiceUUID:self.notificationServiceUUID
                     characteristicUUID:self.notificationAttributesCharacteristicUUID
                            notifyValue:NO];
}

#pragma mark -
#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString]])
    {
        self.lastNotification = [[BDNotificationAttributes alloc] initWithData:characteristic.value];
        if([self.delegate respondsToSelector:@selector(notificationService:didWriteNotification:error:)])
        {
            [self.delegate notificationService:self
                        didReceiveNotification:self.lastNotification
                                         error:error];
        }
    }
    else
    {
        [BDObject peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString]])
    {
        self.lastNotification = [[BDNotificationAttributes alloc] initWithData:characteristic.value];
        
        if([self.delegate respondsToSelector:@selector(notificationService:didReceiveNotification:error:)])
        {
            [self.delegate notificationService:self
                        didReceiveNotification:self.lastNotification
                                         error:error];
        }
    }
    else
    {
        [BDObject peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString]])
    {
        if(characteristic.isNotifying)
        {
            if([self.delegate respondsToSelector:@selector(didSubscribeToStartReceivingNotificationsFor:error:)])
            {
                [self.delegate didSubscribeToStartReceivingNotificationsFor:self error:error];
            }
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(didUnsubscribeToStopRecivingNotificationsFor:error:)])
            {
                [self.delegate didUnsubscribeToStopRecivingNotificationsFor:self error:error];
            }
        }
    }
    else
    {
        [BDObject peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
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
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if([peripheral.identifier isEqual:_servicePeripheral.identifier])
    {
        self.lastNotification = self.lastSentNotification;
        if([self.delegate respondsToSelector:@selector(notificationService:didWriteNotification:error:)])
        {
            [self.delegate notificationService:self
                        didReceiveNotification:self.lastNotification
                                         error:error];
        }
    }

}

- (void)didUpdateValue:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    NSError *error = [payload objectForKey:@"Error"];
    
    self.lastNotification = [[BDNotificationAttributes alloc] initWithData:characteristic.value];
    
    if([self.delegate respondsToSelector:@selector(notificationService:didReceiveNotification:error:)])
    {
        [self.delegate notificationService:self
                    didReceiveNotification:self.lastNotification
                                     error:error];
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
            if([self.delegate respondsToSelector:@selector(didSubscribeToStartReceivingNotificationsFor:error:)])
            {
                [self.delegate didSubscribeToStartReceivingNotificationsFor:self error:error];
            }
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(didUnsubscribeToStopRecivingNotificationsFor:error:)])
            {
                [self.delegate didUnsubscribeToStopRecivingNotificationsFor:self error:error];
            }
        }
    }
}



@end

//
//  NotificationService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "NotificationService.h"
#import "LeDiscoveryManager.h"
#import "BLEduinoPeripheral.h"

#pragma mark -
#pragma mark Notification Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString *kNotificationServiceUUIDString = @"8C6B3141-A312-681D-025B-0032C0D16A2D";
NSString *kNotificationAttributesCharacteristicUUIDString = @"8C6B1618-A312-681D-025B-0032C0D16A2D";


#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*								Setup										*/
/****************************************************************************/
@implementation NotificationService
{
    @private
    CBUUID              *_notificationServiceUUID;
    CBUUID              *_notificationAttributesCharacteristicUUID;
    
    id <NotificationServiceDelegate> _delegate;
    
    NotificationAttributesCharacteristic *_lastNotification;
    
    NSMutableOrderedSet     *_servicePeripherals;
}

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral controller:(id<NotificationServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = self;
		_delegate = aController;
        
        _notificationServiceUUID = [CBUUID UUIDWithString:kNotificationServiceUUIDString];
        _notificationAttributesCharacteristicUUID = [CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString];
    }
    
    return self;
}

#pragma mark -
#pragma mark - Listening Methods
/****************************************************************************/
/*				       Write notification to BLEduino                       */
/****************************************************************************/
/*
 *  @method                 startListening
 *
 *  @discussion             This method subscribes the iOS device to the Notification service for
 *                          all connected BLEduinos. Then listens to incoming data, upon reciving
 *                          data the iOS device then pushes a local notification.
 *
 */
- (void)startListening
{
    self.isListening = YES;
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        CBPeripheral *bleduinoPeripheral = [bleduino copy];
        bleduinoPeripheral.delegate = self;
        
        BLEduinoPeripheral *device = [[BLEduinoPeripheral alloc] init];
        device.bleduino = bleduinoPeripheral;
        
        _servicePeripherals = [[NSMutableOrderedSet alloc] initWithCapacity:leManager.connectedBleduinos.count];
        [_servicePeripherals addObject:device];
        
        [self setNotificationForPeripheral:device.bleduino
                               serviceUUID:_notificationServiceUUID
                        characteristicUUID:_notificationAttributesCharacteristicUUID
                               notifyValue:YES];
    }
}

/*
 *  @method                 stopListening
 *
 *  @discussion             This method unsubscribes the iOS device from the Notification service for
 *                          all connected BLEduinos. That is, stops listening altogether.
 *
 */
- (void)stopListening
{
    for(BLEduinoPeripheral *device in _servicePeripherals)
    {
        [self setNotificationForPeripheral:device.bleduino
                               serviceUUID:_notificationServiceUUID
                        characteristicUUID:_notificationAttributesCharacteristicUUID
                               notifyValue:NO];
    }
 
    //Remove all BLEduinos.
    [_servicePeripherals removeAllObjects];
    
    self.isListening = NO;
}

#pragma mark -
#pragma mark Writing to BLEduino
/****************************************************************************/
/*				       Write notification to BLEduino                       */
/****************************************************************************/
- (void) writeNotification:(NotificationAttributesCharacteristic *)notification
                   withAck:(BOOL)enabled
{
    _lastNotification = notification;
    [self writeDataToPeripheral:_servicePeripheral
                    serviceUUID:_notificationServiceUUID
             characteristicUUID:_notificationAttributesCharacteristicUUID
                           data:[notification data]
                        withAck:enabled];
}

- (void) writeNotification:(NotificationAttributesCharacteristic *)notification
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
    [self readDataFromPeripheral:_servicePeripheral
                     serviceUUID:_notificationServiceUUID
              characteristicUUID:_notificationAttributesCharacteristicUUID];
}

- (void) subscribeToStartReceivingNotifications
{
    [self setNotificationForPeripheral:_servicePeripheral
                           serviceUUID:_notificationServiceUUID
                    characteristicUUID:_notificationAttributesCharacteristicUUID
                           notifyValue:YES];
}

- (void) unsubscribeToStopReiceivingNotifications
{
    [self setNotificationForPeripheral:_servicePeripheral
                           serviceUUID:_notificationServiceUUID
                    characteristicUUID:_notificationAttributesCharacteristicUUID
                           notifyValue:NO];
}

#pragma mark -
#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastNotification = _lastNotification;
    if([_delegate respondsToSelector:@selector(notificationService:didWriteNotification:error:)])
    {
        [_delegate notificationService:self
                didReceiveNotification:self.lastNotification
                                 error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastNotification = [[NotificationAttributesCharacteristic alloc] initWithData:characteristic.value];

    if(self.isListening)
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        //Is application on the foreground?
        if([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)
        {
            //Application is on the foreground, store notification attributes to present alert view.
            notification.userInfo = @{@"title"  : self.lastNotification.title,
                                      @"message": self.lastNotification.message,
                                      @"service": kNotificationAttributesCharacteristicUUIDString};
        }
    
        //Present notification.
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
    else
    {
        if([_delegate respondsToSelector:@selector(notificationService:didReceiveNotification:error:)])
        {
            [_delegate notificationService:self
                    didReceiveNotification:self.lastNotification
                                     error:error];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.isNotifying)
    {
        if([_delegate respondsToSelector:@selector(didSubscribeToStartReceivingNotificationsFor:error:)])
        {
            [_delegate didSubscribeToStartReceivingNotificationsFor:self error:error];
        }
    }
    else
    {
        if([_delegate respondsToSelector:@selector(didUnsubscribeToStopRecivingNotificationsFor:error:)])
        {
            [_delegate didUnsubscribeToStopRecivingNotificationsFor:self error:error];
        }
    }
}



@end

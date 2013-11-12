//
//  NotificationService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleService.h"
#import "NotificationAttributesCharacteristic.h"

#pragma mark -
#pragma mark Notification Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString *kNotificationServiceUUIDString;
//8C6B3141-A312-681D-025B-0032C0D16A2D  Notification Service

extern NSString *kNotificationAttributesCharacteristicUUIDString;
//8C6B1618-A312-681D-025B-0032C0D16A2D  Notification Attributes Characteristic


#pragma mark -
#pragma mark Notification Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class NotificationService;
@protocol NotificationServiceDelegate <NSObject>
@optional
- (void)notificationService:(NotificationService *)service
     didReceiveNotification:(NotificationAttributesCharacteristic *)notification
                      error:(NSError *)error;

- (void)notificationService:(NotificationService *)service
       didWriteNotification:(NotificationAttributesCharacteristic *)notification
                      error:(NSError *)error;

- (void)didSubscribeToStartReceivingNotificationsFor:(NotificationService *)service error:(NSError *)error;
- (void)didUnsubscribeToStopRecivingNotificationsFor:(NotificationService *)service error:(NSError *)error;
@end

/****************************************************************************/
/*                        Notification Service                              */
/****************************************************************************/
@interface NotificationService : BleService <CBPeripheralDelegate>

@property (nonatomic, strong) NotificationAttributesCharacteristic *lastNotification;
@property BOOL isListening;

/*
 *  @method                 startListening
 *
 *  @discussion             This method subscribes the iOS device to the Notification service for
 *                          all connected BLEduinos. Then listens to incoming data, upon reciving
 *                          data the iOS device then pushes a local notification.
 *
 */
- (void)startListening;

/*
 *  @method                 stopListening
 *
 *  @discussion             This method unsubscribes the iOS device from the Notification service for
 *                          all connected BLEduinos. That is, stops listening altogether.
 *
 */
- (void)stopListening;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral controller:(id<NotificationServiceDelegate>)aController;

#pragma mark -
#pragma mark Writing to BLEduino
// Write notifications to BLEduino.
- (void) writeNotification:(NotificationAttributesCharacteristic *)notification withAck:(BOOL)enabled;
- (void) writeNotification:(NotificationAttributesCharacteristic *)notification;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving notifications from BLEduino.
- (void) readNotification;
- (void) subscribeToStartReceivingNotifications;
- (void) unsubscribeToStopReiceivingNotifications;

@end

//
//  NotificationService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDBleService.h"
#import "BDNotificationAttributes.h"

#pragma mark -
#pragma mark Notification Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString * const kNotificationServiceUUIDString;
//8C6B3141-A312-681D-025B-0032C0D16A2D  Notification Service

extern NSString * const kNotificationAttributesCharacteristicUUIDString;
//8C6B1618-A312-681D-025B-0032C0D16A2D  Notification Attributes Characteristic


#pragma mark -
#pragma mark Notification Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BDNotification;
@protocol NotificationServiceDelegate <NSObject>
@optional
- (void)didStatedListening:(BDNotification *)service;
- (void)didFailToStartListening:(BDNotification *)service;

- (void)notificationService:(BDNotification *)service
     didReceiveNotification:(BDNotificationAttributes *)notification
                      error:(NSError *)error;

- (void)notificationService:(BDNotification *)service
       didWriteNotification:(BDNotificationAttributes *)notification
                      error:(NSError *)error;

- (void)didSubscribeToStartReceivingNotificationsFor:(BDNotification *)service error:(NSError *)error;
- (void)didUnsubscribeToStopRecivingNotificationsFor:(BDNotification *)service error:(NSError *)error;
@end

/****************************************************************************/
/*                        Notification Service                              */
/****************************************************************************/
@interface BDNotification : BDBleService <CBPeripheralDelegate>

@property (nonatomic, strong) BDNotificationAttributes *lastNotification;
@property BOOL isListening;

/*
 *  @method                 startListening
 *
 *  @discussion             This method subscribes the iOS device to the Notification service for
 *                          all connected BLEduinos. Then listens to incoming data, upon reciving
 *                          data the iOS device then pushes a local notification.
 *
 */
- (void)startListeningWithDelegate:(id<NotificationServiceDelegate>)aController;
/*
 *  @method                 stopListening
 *
 *  @discussion             This method unsubscribes the iOS device from the Notification service for
 *                          all connected BLEduinos. That is, stops listening altogether.
 *
 */
- (void)stopListeningWithDelegate:(id<NotificationServiceDelegate>)aController;


- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<NotificationServiceDelegate>)aController;

/****************************************************************************/
/*              Access to notificication listener instance			  	    */
/****************************************************************************/
+ (BDNotification *)sharedListener;


#pragma mark -
#pragma mark Writing to BLEduino
// Write notifications to BLEduino.
- (void) writeNotification:(BDNotificationAttributes *)notification withAck:(BOOL)enabled;
- (void) writeNotification:(BDNotificationAttributes *)notification;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving notifications from BLEduino.
- (void) readNotification;
- (void) subscribeToStartReceivingNotifications;
- (void) unsubscribeToStopReiceivingNotifications;

@end

//
//  NotificationService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDBleService.h"
#import "BDNotificationAttributesCharacteristic.h"

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
@class BDNotificationService;
@protocol NotificationServiceDelegate <NSObject>
@optional
- (void)notificationService:(BDNotificationService *)service
     didReceiveNotification:(BDNotificationAttributesCharacteristic *)notification
                      error:(NSError *)error;

- (void)notificationService:(BDNotificationService *)service
       didWriteNotification:(BDNotificationAttributesCharacteristic *)notification
                      error:(NSError *)error;

- (void)didSubscribeToStartReceivingNotificationsFor:(BDNotificationService *)service error:(NSError *)error;
- (void)didUnsubscribeToStopRecivingNotificationsFor:(BDNotificationService *)service error:(NSError *)error;
@end

/****************************************************************************/
/*                        Notification Service                              */
/****************************************************************************/
@interface BDNotificationService : BDBleService <CBPeripheralDelegate>

@property (nonatomic, strong) BDNotificationAttributesCharacteristic *lastNotification;
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


- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<NotificationServiceDelegate>)aController;

/****************************************************************************/
/*              Access to notificication listener instance			  	    */
/****************************************************************************/
+ (BDNotificationService *)sharedListener;


#pragma mark -
#pragma mark Writing to BLEduino
// Write notifications to BLEduino.
- (void) writeNotification:(BDNotificationAttributesCharacteristic *)notification withAck:(BOOL)enabled;
- (void) writeNotification:(BDNotificationAttributesCharacteristic *)notification;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving notifications from BLEduino.
- (void) readNotification;
- (void) subscribeToStartReceivingNotifications;
- (void) unsubscribeToStopReiceivingNotifications;

@end

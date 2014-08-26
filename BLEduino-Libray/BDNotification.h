//
//  NotificationService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDObject.h"
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
@required
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
@interface BDNotification : BDObject <CBPeripheralDelegate>

@property (nonatomic, strong) BDNotificationAttributes *lastNotification;

/****************************************************************************/
/*              Access to notificication listener instance			  	    */
/****************************************************************************/
- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<NotificationServiceDelegate>)aController;


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

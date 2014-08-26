//
//  BDNotifications.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/26/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "BDObject.h"
#import "BDNotification.h"

#pragma mark -
#pragma mark Notifications Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BDNotifications;
@protocol NotificationsDelegate <NSObject>
@required
- (void)didStartListening:(BDNotifications *)service;
- (void)didFailToStartListening:(BDNotifications *)service;
@end

/****************************************************************************/
/*                        Notification Service                              */
/****************************************************************************/
@interface BDNotifications : NSObject  <CBPeripheralDelegate>
@property BOOL isListening;

/*
 *  @method                 startListening
 *
 *  @discussion             This method subscribes the iOS device to the Notification service for
 *                          all connected BLEduinos. Then listens to incoming data, upon reciving
 *                          data the iOS device then pushes a local notification.
 *
 */
- (void)startListeningWithDelegate:(id<NotificationsDelegate>)aController;
/*
 *  @method                 stopListening
 *
 *  @discussion             This method unsubscribes the iOS device from the Notification service for
 *                          all connected BLEduinos. That is, stops listening altogether.
 *
 */
- (void)stopListening;


/****************************************************************************/
/*              Access to notificication listener instance			  	    */
/****************************************************************************/
+ (BDNotifications *)sharedListener;

@end


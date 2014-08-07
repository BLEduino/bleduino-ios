//
//  NotificationService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDNotificationService.h"
#import "BDLeDiscoveryManager.h"
#import "BDPeripheral.h"

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
@interface BDNotificationService ()

@property (strong) CBUUID *notificationServiceUUID;
@property (strong) CBUUID *notificationAttributesCharacteristicUUID;

@property (weak) id <NotificationServiceDelegate> delegate;
@property (strong) BDNotificationAttributesCharacteristic *lastSentNotification;

@property (strong) NSMutableOrderedSet *notifications;
@end

@implementation BDNotificationService

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<NotificationServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = self;
		self.delegate = aController;
        
        self.notificationServiceUUID = [CBUUID UUIDWithString:kNotificationServiceUUIDString];
        self.notificationAttributesCharacteristicUUID = [CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString];
    }
    
    return self;
}


+ (BDNotificationService *)sharedListener
{
    static id sharedNotificationListener = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNotificationListener = [[[self class] alloc] init];
    });
    return sharedNotificationListener;
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
- (void)startListeningWithDelegate:(id<NotificationServiceDelegate>)aController
{
    //Start listening only if there is not another notification (service) already listening.
    if(!self.isListening)
    {
        self.isListening = YES; //Notifications started listening.
        BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
        self.notifications = [[NSMutableOrderedSet alloc] initWithCapacity:leManager.connectedBleduinos.count];
        
        for(CBPeripheral *bleduino in leManager.connectedBleduinos)
        {
            BDNotificationService *notification = [[BDNotificationService alloc] initWithPeripheral:bleduino
                                                                                           delegate:aController];
            
            [notification subscribeToStartReceivingNotifications];
            notification.isListening = YES;
            [self.notifications addObject:notification];
        }
        
        NSLog(@"Notifications: Startted listening.");
    }
}

/*
 *  @method                 stopListening
 *
 *  @discussion             This method unsubscribes the iOS device from the Notification service for
 *                          all connected BLEduinos. That is, stops listening altogether.
 *
 */
- (void)stopListeningWithDelegate:(id<NotificationServiceDelegate>)aController
{
    for(BDNotificationService *notification in self.notifications)
    {
        [notification dismissPeripheral];
        [notification unsubscribeToStopReiceivingNotifications];
    }
 
    //Remove all BLEduinos.
    [self.notifications removeAllObjects];
    
    self.isListening = NO;
    NSLog(@"Notifications: Stopped listening.");
}

#pragma mark -
#pragma mark Writing to BLEduino
/****************************************************************************/
/*				       Write notification to BLEduino                       */
/****************************************************************************/
- (void) writeNotification:(BDNotificationAttributesCharacteristic *)notification
                   withAck:(BOOL)enabled
{
    self.lastSentNotification = notification;
    [self writeDataToServiceUUID:self.notificationServiceUUID
              characteristicUUID:self.notificationAttributesCharacteristicUUID
                            data:[notification data]
                         withAck:enabled];
}

- (void) writeNotification:(BDNotificationAttributesCharacteristic *)notification
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
    self.lastNotification = self.lastSentNotification;
    if([self.delegate respondsToSelector:@selector(notificationService:didWriteNotification:error:)])
    {
        [self.delegate notificationService:self
                    didReceiveNotification:self.lastNotification
                                     error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastNotification = [[BDNotificationAttributesCharacteristic alloc] initWithData:characteristic.value];

    if(self.isListening)
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody = self.lastNotification.message;
        notification.alertAction = nil;
        
        //Is application on the foreground?
        if([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)
        {
            //Application is on the foreground, store notification attributes to present alert view.
            notification.userInfo = @{@"message": self.lastNotification.message,
                                      @"service": kNotificationAttributesCharacteristicUUIDString};
        }
    
        //Present notification.
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(notificationService:didReceiveNotification:error:)])
        {
            [self.delegate notificationService:self
                        didReceiveNotification:self.lastNotification
                                         error:error];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
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



@end

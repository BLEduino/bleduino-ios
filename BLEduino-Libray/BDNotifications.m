//
//  BDNotifications.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/26/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "BDNotifications.h"
#import "BDNotification.h"
#import "BDLeManager.h"

#pragma mark -
#pragma mark - Private Class
/****************************************************************************/
/*								Notification    							*/
/****************************************************************************/
@interface Notification : BDObject
@property (strong) CBUUID *notificationServiceUUID;
@property (strong) CBUUID *notificationAttributesCharacteristicUUID;
@end

@implementation Notification

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<CBPeripheralDelegate>)delegate
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        
        //Should this object be the peripheral's delagate, or are we using the global delegate?
        BDLeManager *manager = [BDLeManager sharedLeManager];
        if(!manager.isOnlyBleduinoDelegate) _servicePeripheral.delegate = delegate;
        
        self.notificationServiceUUID = [CBUUID UUIDWithString:kNotificationServiceUUIDString];
        self.notificationAttributesCharacteristicUUID = [CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString];
    }
    
    return self;
}

@end

@interface BDNotifications()
@property (weak) id <NotificationsDelegate> delegate;
@property (strong) NSMutableOrderedSet *notifications;
@property (strong) NSArray *bleduinos;
@end

@implementation BDNotifications

+ (BDNotifications *)sharedListener
{
    static id sharedNotificationListener = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNotificationListener = [[[self class] alloc] init];
    });
    return sharedNotificationListener;
}

- (id)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didUpdateValue:) name:CHARACTERISTIC_UPDATE_NOTIFICATION object:nil];
        [center addObserver:self selector:@selector(didNotifyUpdate:) name:CHARACTERISTIC_NOTIFY_NOTIFICATION object:nil];
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
- (void)startListeningWithDelegate:(id<NotificationsDelegate>)aController
{
    //Start listening only if there is not another notification (service) already listening.
    if(!self.isListening)
    {
        self.isListening = YES; //Notifications started listening.
        self.delegate = aController;
        
        BDLeManager *leManager = [BDLeManager sharedLeManager];
        self.notifications = [[NSMutableOrderedSet alloc] initWithCapacity:leManager.connectedBleduinos.count];
        self.bleduinos = [NSArray arrayWithArray:[leManager.connectedBleduinos array]];
        
        if(leManager.connectedBleduinos.count > 0)
        {
            for(CBPeripheral *bleduino in leManager.connectedBleduinos)
            {
                Notification *notification = [[Notification alloc] initWithPeripheral:bleduino delegate:self];
                [self.notifications addObject:notification];
                
                [notification setNotificationForServiceUUID:notification.notificationServiceUUID
                                         characteristicUUID:notification.notificationAttributesCharacteristicUUID
                                                notifyValue:YES];
            }
            
            NSLog(@"Notifications: Started listening.");
            [self.delegate didStartListening:self];
        }
        else
        {
            NSLog(@"Notifications: Unable to start listening.");
            [self.delegate didFailToStartListening:self];
        }
        
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
    for(Notification *notification in self.notifications)
    {
        [notification dismissPeripheral];
        [notification setNotificationForServiceUUID:notification.notificationServiceUUID
                                 characteristicUUID:notification.notificationAttributesCharacteristicUUID
                                        notifyValue:NO];
    }
    
    //Remove all BLEduinos.
    [self.notifications removeAllObjects];
    
    self.isListening = NO;
    NSLog(@"Notifications: Stopped listening.");
}

#pragma mark -
#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [BDObject peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString]])
    {
        NSString *message = [[BDNotificationAttributes alloc] initWithData:characteristic.value].message;
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody = message;
        notification.alertAction = nil;
        
        //Is application on the foreground?
        if([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)
        {
            //Application is on the foreground, store notification attributes to present alert view.
            notification.userInfo = @{@"message": message,
                                      @"service": kNotificationAttributesCharacteristicUUIDString};
        }
        
        //Present notification.
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
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
        if(error == nil)
        {
            NSLog(@"Did subscribe to notifications attributes char for peripheral: %@", peripheral.identifier);
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
- (void)didUpdateValue:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if([self.bleduinos containsObject:peripheral] && error == nil)
    {
        NSString *message = [[BDNotificationAttributes alloc] initWithData:characteristic.value].message;
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = message;
        localNotification.alertAction = nil;
        
        //Is application on the foreground?
        if([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)
        {
            //Application is on the foreground, store notification attributes to present alert view.
            localNotification.userInfo = @{@"message": message,
                                           @"service": kNotificationAttributesCharacteristicUUIDString};
        }
        
        //Present notification.
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

- (void)didNotifyUpdate:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if([self.bleduinos containsObject:peripheral] && error == nil)
    {
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotificationAttributesCharacteristicUUIDString]])
        {
            if(error == nil)
            {
                NSLog(@"Did subscribe to notifications attributes char for peripheral: %@", peripheral.identifier);
            }
        }
        else
        {
            [BDObject peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
        }
    }
}

@end

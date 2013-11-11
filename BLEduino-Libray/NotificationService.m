//
//  NotificationService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "NotificationService.h"

#pragma mark -
#pragma mark Notification Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString *kNotificationServiceUUIDString = @"8C6B3141-A312-681D-025B-0032C0D16A2D";
NSString *kNotificationAttributesCharacteristicUUIDString = @"8C6B1618-A312-681D-025B-0032C0D16A2D";

@implementation NotificationService
{
    @private
    CBUUID              *_notificationServiceUUID;
    CBUUID              *_notificationAttributesCharacteristicUUID;
}



@end

//
//  NotificationService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleService.h"

/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString *kNotificationServiceUUIDString;
//8C6B3141-A312-681D-025B-0032C0D16A2D  Notification Service

extern NSString *kNotificationAttributesCharacteristicUUIDString;
//8C6B1618-A312-681D-025B-0032C0D16A2D  Notification Attributes Characteristic

@interface NotificationService : BleService


@end

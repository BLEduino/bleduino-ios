//
//  NotificationAttributesCharacteristic.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/11/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDNotificationAttributes : NSObject

//Notifications have two attributes: title and message;
@property (strong) NSString *title;
@property (strong) NSString *message;

/*
 * Create Notification Attributes characteristic from NSData object.
 */
- (id) initWithData:(NSData *)attributesData;

/*
 * Create Notification Attributes. 
 */
+ (instancetype)attributes;

/*
 * Converts Notification Attributes characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data;
@end

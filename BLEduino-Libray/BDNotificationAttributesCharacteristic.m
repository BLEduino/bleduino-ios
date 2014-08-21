//
//  NotificationAttributesCharacteristic.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/11/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDNotificationAttributesCharacteristic.h"

@implementation BDNotificationAttributesCharacteristic

/*
 * Create Throttle-Yaw-Roll-Pitch characteristic from NSData object.
 */
- (id) initWithData:(NSData *)attributesData
{
    self = [super init];
    if(self)
    {
        _message =  [[NSString alloc] initWithData:attributesData
                                          encoding:NSUTF8StringEncoding];

    }

    return self;
}

/*
 * Converts Throttle-Yaw-Roll-Pitch characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data
{
    NSData *attributesData = [self.message dataUsingEncoding:NSUTF8StringEncoding];
    
    return attributesData;
}

@end

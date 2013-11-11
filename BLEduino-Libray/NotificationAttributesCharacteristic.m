//
//  NotificationAttributesCharacteristic.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/11/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "NotificationAttributesCharacteristic.h"

@implementation NotificationAttributesCharacteristic

/*
 * Create Throttle-Yaw-Roll-Pitch characteristic from NSData object.
 */
- (id) initWithData:(NSData *)attributesData
{
    NSString *attributesString = [[NSString alloc] initWithData:attributesData
                                                  encoding:NSUTF8StringEncoding];

    NSArray *attributes = [attributesString componentsSeparatedByString:@"#"];
    self.title = [attributes objectAtIndex:0];
    self.message = [attributes objectAtIndex:1];

    return self;
}

/*
 * Converts Throttle-Yaw-Roll-Pitch characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data
{
    NSString *attributesString = [NSString stringWithFormat:@"%@#%@", self.title, self.message];
    NSData *attributesData = [attributesString dataUsingEncoding:NSUTF8StringEncoding];
    
    return attributesData;
}

@end

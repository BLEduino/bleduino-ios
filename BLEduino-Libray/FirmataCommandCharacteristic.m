//
//  FirmataCommandCharacteristic.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/6/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "FirmataCommandCharacteristic.h"

@implementation FirmataCommandCharacteristic

/*
 * Create Firmata Command characteristic from NSData object.
 */
- (id) initWithData:(NSData *)firmataCommandData
{
    return nil;
}

/*
 * Converts Firmata Command characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data
{
//    NSMutableData *firmataCommandData = [[NSMutableData alloc] initWithCapacity:3];
//    
//    int pinSate = self.pinState;
//    NSData *dataThrottle = [NSData dataWithBytes:&throttle length:sizeof(throttle)];
//    [motionData appendData:dataThrottle];
//    
//    int pinNumber = [self.pinNumber floatValue];
//    NSData *dataYaw = [NSData dataWithBytes:&yaw length:sizeof(yaw)];
//    [motionData appendData:dataYaw];
//    
//    int pinValue = [self.pinValue floatValue];
//    NSData *dataRoll = [NSData dataWithBytes:&roll length:sizeof(roll)];
//    [motionData appendData:dataRoll];
//    
//    return firmataCommandData;
    
    return nil;
}


@end

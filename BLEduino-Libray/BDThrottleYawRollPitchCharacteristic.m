//
//  Motion.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/4/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDThrottleYawRollPitchCharacteristic.h"

@implementation BDThrottleYawRollPitchCharacteristic

/*
 * Create Throttle-Yaw-Roll-Pitch characteristic from NSData object.
 */
- (id) initWithData:(NSData *)motionData
{
    self = [super init];
    if(self)
    {
        Byte *throttleByte = (Byte*)malloc(1);
        NSRange throttleRange = NSMakeRange(0, 1);
        [motionData getBytes:throttleByte range:throttleRange];
        NSData *throttleData = [[NSData alloc] initWithBytes:throttleByte length:1];
        _throttle = *(int*)([throttleData bytes]);
        
        Byte *yawByte = (Byte*)malloc(1);
        NSRange yawRange = NSMakeRange(1, 1);
        [motionData getBytes:yawByte range:yawRange];
        NSData *yawData = [[NSData alloc] initWithBytes:yawByte length:1];
        _yaw = *(int*)([yawData bytes]);
        
        Byte *rollByte = (Byte*)malloc(1);
        NSRange rollRange = NSMakeRange(2, 1);
        [motionData getBytes:rollByte range:rollRange];
        NSData *rollData = [[NSData alloc] initWithBytes:rollByte length:1];
        _roll = *(int*)([rollData bytes]);
        
        Byte *pitchByte = (Byte*)malloc(1);
        NSRange pitchRange = NSMakeRange(3, 1);
        [motionData getBytes:pitchByte range:pitchRange];
        NSData *pitchData = [[NSData alloc] initWithBytes:pitchByte length:1];
        _pitch = *(int*)([pitchData bytes]);
    }
    return self;
}

/*
 * Converts Throttle-Yaw-Roll-Pitch characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data
{
    NSMutableData *motionData = [[NSMutableData alloc] initWithCapacity:4];
    
    Byte throttleByte = (self.throttle >> (0)) & 0xff;
    NSMutableData *throttleData = [NSMutableData dataWithBytes:&throttleByte length:sizeof(throttleByte)];
    [motionData appendData:throttleData];
    
    Byte yawByte = (self.yaw >> (0)) & 0xff;
    NSMutableData *yawData = [NSMutableData dataWithBytes:&yawByte length:sizeof(yawByte)];
    [motionData appendData:yawData];
    
    Byte rollByte = (self.roll >> (0)) & 0xff;
    NSMutableData *rollData = [NSMutableData dataWithBytes:&rollByte length:sizeof(rollByte)];
    [motionData appendData:rollData];
    
    Byte pitchByte = (self.pitch >> (0)) & 0xff;
    NSMutableData *pitchData = [NSMutableData dataWithBytes:&pitchByte length:sizeof(pitchByte)];
    [motionData appendData:pitchData];
    
    return motionData;
}

@end

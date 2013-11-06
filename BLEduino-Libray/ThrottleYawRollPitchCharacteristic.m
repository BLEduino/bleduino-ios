//
//  Motion.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/4/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "ThrottleYawRollPitchCharacteristic.h"

@implementation ThrottleYawRollPitchCharacteristic

/*
 * Create Throttle-Yaw-Roll-Pitch characteristic from NSData object.
 */
- (id) initWithData:(NSData *)motionData
{
    Byte *throttleByte = (Byte*)malloc(1);
    NSRange throttleRange = NSMakeRange(0, 1);
    [motionData getBytes:throttleByte range:throttleRange];
    NSData *throttleData = [[NSData alloc] initWithBytes:throttleByte length:1];
    int throttleValue = *(int*)([throttleData bytes]);
    self.throttle = [NSNumber numberWithInt:throttleValue];
    
    Byte *yawByte = (Byte*)malloc(1);
    NSRange yawRange = NSMakeRange(1, 1);
    [motionData getBytes:yawByte range:yawRange];
    NSData *yawData = [[NSData alloc] initWithBytes:yawByte length:1];
    int yawValue = *(int*)([yawData bytes]);
    self.yaw = [NSNumber numberWithInt:yawValue];
    
    Byte *rollByte = (Byte*)malloc(1);
    NSRange rollRange = NSMakeRange(2, 1);
    [motionData getBytes:rollByte range:rollRange];
    NSData *rollData = [[NSData alloc] initWithBytes:rollByte length:1];
    int rollValue = *(int*)([rollData bytes]);
    self.roll = [NSNumber numberWithInt:rollValue];
    
    Byte *pitchByte = (Byte*)malloc(1);
    NSRange pitchRange = NSMakeRange(3, 1);
    [motionData getBytes:pitchByte range:pitchRange];
    NSData *pitchData = [[NSData alloc] initWithBytes:pitchByte length:1];
    int pitchValue = *(int*)([pitchData bytes]);
    self.pitch = [NSNumber numberWithInt:pitchValue];
    
    return self;
    
}

/*
 * Converts Throttle-Yaw-Roll-Pitch characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data
{
    NSMutableData *motionData = [[NSMutableData alloc] initWithCapacity:4];
    
    float throttle = [self.throttle floatValue];
    NSData *dataThrottle = [NSData dataWithBytes:&throttle length:sizeof(throttle)];
    [motionData appendData:dataThrottle];
    
    float yaw = [self.yaw floatValue];
    NSData *dataYaw = [NSData dataWithBytes:&yaw length:sizeof(yaw)];
    [motionData appendData:dataYaw];
    
    float roll = [self.roll floatValue];
    NSData *dataRoll = [NSData dataWithBytes:&roll length:sizeof(roll)];
    [motionData appendData:dataRoll];

    float pitch = [self.pitch floatValue];
    NSData *dataPitch = [NSData dataWithBytes:&pitch length:sizeof(pitch)];
    [motionData appendData:dataPitch];
    
    return motionData;
}

@end

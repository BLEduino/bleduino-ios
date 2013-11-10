//
//  Motion.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/4/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThrottleYawRollPitchCharacteristic : NSObject
@property (nonatomic) NSInteger throttle;
@property (nonatomic) NSInteger pitch;
@property (nonatomic) NSInteger roll;
@property (nonatomic) NSInteger yaw;

/*
 * Create Throttle-Yaw-Roll-Pitch characteristic from NSData object. 
 */
- (id) initWithData:(NSData *)motionData;

/*
 * Converts Throttle-Yaw-Roll-Pitch characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data;

@end

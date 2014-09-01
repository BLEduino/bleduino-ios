//
//  Motion.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/4/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDThrottleYawRollPitch : NSObject
@property  NSInteger throttle;
@property  NSInteger pitch;
@property  NSInteger roll;
@property  NSInteger yaw;

/*
 * Create Throttle-Yaw-Roll-Pitch characteristic from NSData object. 
 */
- (id) initWithData:(NSData *)motionData;

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
+ (instancetype)motion;

/*
 * Converts Throttle-Yaw-Roll-Pitch characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data;

@end

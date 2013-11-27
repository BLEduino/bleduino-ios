//
//  ButtonActionCharacteristic.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/10/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDButtonActionCharacteristic : NSObject

/*
 * Identifies the button.
 */
@property NSInteger buttonID;

/*
 * For push buttons. 
 * State: 1 denotes pushed down.
 * State: 0 denotes neutral
 */
@property NSInteger buttonStatus;

/*
 * For joystick buttons.
 * Resolution: -90 < X < 90
 * State: -90 denotes completely pushed down, represented as 0.
 * State:  90 denotes completely pushed up, represented as 254.
 * State:   0 denotes neutral, represented as 127.
 * State: -90 < X < 0  denotes down, represented as 0 < X < 127.
 * State:   0 < X < 90 denotes up, represented as 127 < X < 255.
 */
@property NSInteger buttonValue;

/*
 * Create Throttle-Yaw-Roll-Pitch characteristic from NSData object.
 */
- (id) initWithData:(NSData *)buttonActionData;

/*
 * Converts Throttle-Yaw-Roll-Pitch characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data;
@end

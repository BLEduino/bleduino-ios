//
//  FirmataCommandCharacteristic.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/6/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    FirmataCommandPinStateOutput = 0,
    FirmataCommandPinStateInput = 1,
    FirmataCommandPinStatePWM = 2,
    FirmataCommandPinStateAnalog = 3
};
typedef NSUInteger FirmataCommandPinState;

@interface FirmataCommandCharacteristic : NSObject

@property (nonatomic) FirmataCommandPinState pinState;
@property (nonatomic) NSInteger pinNumber;
@property (nonatomic) NSInteger pinValue;

/*
 * Create Firmata Command characteristic from NSData object.
 */
- (id) initWithData:(NSData *)firmataData;

/*
 * Converts Firmata Command characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data;

@end

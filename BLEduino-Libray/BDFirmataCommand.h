//
//  FirmataCommandCharacteristic.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/6/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 ## Pin Numbers
 
 Pin numbers are set according to the [pin definition for Arduino.]
 (https://github.com/BLEduino/bleduino-firmware/blob/master/hardware/BLEduino/variants/BLEduino/pins_arduino.h/ )
 
 */


enum {
    FirmataCommandPinStateOutput = 0,
    FirmataCommandPinStateInput = 1,
    FirmataCommandPinStateAnalog = 2,
    FirmataCommandPinStatePWM = 3
    
    //Work-around, only for sequencer module.
    //Begining (of sequence) = 4
    //End (of sequence) = 5
    //Time delay in seconds = 6
    //Time delay in minutes = 7
};
typedef NSUInteger FirmataCommandPinState;

@interface BDFirmataCommand : NSObject
@property FirmataCommandPinState pinState;
@property NSInteger pinNumber;
@property NSInteger pinValue;


/*
 * Create Firmata Command.
 */
- (id) initWithPinState:(FirmataCommandPinState)state
              pinNumber:(NSInteger)number
               pinValue:(NSInteger)value;

/*
 * Create Firmata Command.
 */
+ (id) commandPinState:(FirmataCommandPinState)state
             pinNumber:(NSInteger)number
              pinValue:(NSInteger)value;

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
+ (instancetype)command;

/*
 * Create Firmata Command characteristic from NSData object.
 */
- (id) initWithData:(NSData *)firmataData;

/*
 * Converts Firmata Command characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data;

@end

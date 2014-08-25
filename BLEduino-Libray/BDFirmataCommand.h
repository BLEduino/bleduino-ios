//
//  FirmataCommandCharacteristic.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/6/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>

//PIN NUMBER LOOKUP TABLE
//FIRMATA_PIN0 = 0
//FIRMATA_PIN1 = 1
//FIRMATA_PIN2 = 2
//FIRMATA_PIN3 = 3
//FIRMATA_PIN4 = 4
//FIRMATA_PIN5 = 5
//FIRMATA_PIN6 = 6
//FIRMATA_PIN7 = 7
//FIRMATA_PIN8 = 8
//FIRMATA_PIN9 = 9
//FIRMATA_PIN10 = 10
//FIRMATA_PIN13 = 11
//FIRMATA_PINA0 = 12
//FIRMATA_PINA1 = 13
//FIRMATA_PINA2 = 14
//FIRMATA_PINA3 = 15
//FIRMATA_PINA4 = 16
//FIRMATA_PINA5 = 17
//FIRMATA_PIN_MISO = 18
//FIRMATA_PIN_MOSI = 19
//FIRMATA_PIN_SCK = 20

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
 * Create Firmata Command.
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

//
//  FirmataCommandCharacteristic.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/6/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDFirmataCommandCharacteristic.h"

@implementation BDFirmataCommandCharacteristic

/*
 * Create Firmata Command.
 */
- (id) initWithPinState:(FirmataCommandPinState)state
              pinNumber:(NSInteger)number
               pinValue:(NSInteger)value
{
    self = [super init];
    if(self)
    {
        self.pinState = state;
        self.pinNumber = number;
        self.pinValue = value;
    }

    return self;
}

/*
 * Create Firmata Command.
 */
+ (id) commandPinState:(FirmataCommandPinState)state
             pinNumber:(NSInteger)number
              pinValue:(NSInteger)value
{
    BDFirmataCommandCharacteristic *command =
    [[BDFirmataCommandCharacteristic alloc] initWithPinState:state
                                                   pinNumber:number
                                                    pinValue:value];
    
    return command;
}

/*
 * Create Firmata Command characteristic from NSData object.
 */
- (id) initWithData:(NSData *)firmataCommandData
{
    self = [super init];
    if(self)
    {
        //Converting pinNumber byte to integer.
        Byte *pinNumberByte = (Byte*)malloc(1);
        NSRange pinNumberRange = NSMakeRange(0, 1);
        [firmataCommandData getBytes:pinNumberByte range:pinNumberRange];
        NSData *pinNumberData = [[NSData alloc] initWithBytes:pinNumberByte length:1];
        self.pinNumber = *(int*)([pinNumberData bytes]);
        
        //Converting pinState byte to corresponding FirmataCommandPinState.
        Byte *pinStateByte = (Byte*)malloc(1);
        NSRange pinStateRange = NSMakeRange(1, 1);
        [firmataCommandData getBytes:pinStateByte range:pinStateRange];
        NSData *pinStateData = [[NSData alloc] initWithBytes:pinStateByte length:1];
        self.pinState = *(int*)([pinStateData bytes]);
        
        //Converting pinValue byte to integer.
        Byte *pinValueByte = (Byte*)malloc(1);
        NSRange pinValueRange = NSMakeRange(2, 1);
        [firmataCommandData getBytes:pinValueByte range:pinValueRange];
        NSData *pinValueData = [[NSData alloc] initWithBytes:pinValueByte length:1];
        self.pinValue = *(int*)([pinValueData bytes]);
    }
    return self;
}

/*
 * Converts Firmata Command characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data
{
    NSMutableData *firmataCommandData = [[NSMutableData alloc] initWithCapacity:3];
    
    Byte pinNumberByte = (self.pinNumber >> (0)) & 0xff;
    NSMutableData *pinNumberData = [NSMutableData dataWithBytes:&pinNumberByte length:sizeof(pinNumberByte)];
    [firmataCommandData appendData:pinNumberData];

    Byte pinStateByte = (self.pinState >> (0)) & 0xff;
    NSMutableData *pinStateData = [NSMutableData dataWithBytes:&pinStateByte length:sizeof(pinStateByte)];
    [firmataCommandData appendData:pinStateData];
    
    Byte pinValueByte = (self.pinState >> (0)) & 0xff;
    NSMutableData *pinValueData = [NSMutableData dataWithBytes:&pinValueByte length:sizeof(pinValueByte)];
    [firmataCommandData appendData:pinValueData];
    
    return firmataCommandData;
}


@end

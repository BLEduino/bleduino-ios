//
//  ButtonActionCharacteristic.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/10/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDButtonActionCharacteristic.h"

@implementation BDButtonActionCharacteristic

/*
 * Create Button Action characteristic from NSData object.
 */
- (id) initWithData:(NSData *)buttonActionData
{
    self = [super init];
    if (self)
    {
        Byte *buttonIDByte = (Byte*)malloc(1);
        NSRange buttonIDRange = NSMakeRange(0, 1);
        [buttonActionData getBytes:buttonIDByte range:buttonIDRange];
        NSData *buttonIDData = [[NSData alloc] initWithBytes:buttonIDByte length:1];
        _buttonID = *(int*)([buttonIDData bytes]);
        
        Byte *buttonStatusByte = (Byte*)malloc(1);
        NSRange buttonStatusRange = NSMakeRange(1, 1);
        [buttonActionData getBytes:buttonStatusByte range:buttonStatusRange];
        NSData *buttonStatusData = [[NSData alloc] initWithBytes:buttonStatusByte length:1];
        _buttonStatus = *(int*)([buttonStatusData bytes]);
        
        Byte *buttonValueByte = (Byte*)malloc(1);
        NSRange buttonValueRange = NSMakeRange(2, 1);
        [buttonActionData getBytes:buttonValueByte range:buttonValueRange];
        NSData *buttonValueData = [[NSData alloc] initWithBytes:buttonValueByte length:1];
        _buttonValue = *(int*)([buttonValueData bytes]);
    }

    return self;
}

/*
 * Converts Button Action characteristic to an NSData object to send data to a peripheral.
 */
- (NSData *)data
{
    NSMutableData *buttonActionData = [[NSMutableData alloc] initWithCapacity:4];
    
    Byte buttonIDByte = (self.buttonID >> (0)) & 0xff;
    NSMutableData *buttonIDData = [NSMutableData dataWithBytes:&buttonIDByte length:sizeof(buttonIDByte)];
    [buttonActionData appendData:buttonIDData];
    
    Byte buttonStatusByte = (self.buttonStatus >> (0)) & 0xff;
    NSMutableData *buttonStatusData = [NSMutableData dataWithBytes:&buttonStatusByte length:sizeof(buttonStatusByte)];
    [buttonActionData appendData:buttonStatusData];
    
    Byte buttonValueByte = (self.buttonValue >> (0)) & 0xff;
    NSMutableData *buttonValueData = [NSMutableData dataWithBytes:&buttonValueByte length:sizeof(buttonValueByte)];
    [buttonActionData appendData:buttonValueData];
    
    return buttonActionData;
}

@end

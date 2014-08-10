//
//  BDWrite.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/7/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "BDWrite.h"
#import "BDFirmataCommandCharacteristic.h"
#import "BDFirmataService.h"

@interface BDWrite ()
@property id delegate;
@end
@implementation BDWrite


+ (void) writeData:(id)data
              pipe:(BlePipe)pipe
            device:(CBPeripheral *)bleduino
          delegate:(id)delegate
{
    BDWrite *write = [[BDWrite alloc] init];
    
    if(pipe == Firmata && [data isKindOfClass:[BDFirmataCommandCharacteristic class]])
    {
        BDFirmataCommandCharacteristic *command = (BDFirmataCommandCharacteristic *)data;
        BDFirmataService *firmata = [[BDFirmataService alloc] initWithPeripheral:bleduino delegate:write];
        [firmata writeFirmataCommand:command];
    }
    
    switch (pipe) {
        case Firmata:
        {
            BDFirmataService *firmata = [[BDFirmataService alloc] initWithPeripheral:bleduino delegate:write];
            [firmata readFirmataCommand];
        }
            break;
        case UART:
        {
            
        }
            break;
        case Notification:
        {
            
        }
            break;
        case BleBridge:
        {
            
        }
            break;
        case Controller:
        {
            
        }
            break;
        case VehicleMotion:
        {
            
        }
            break;
    }
}

+ (instancetype) readDataPipe:(BlePipe)pipe
                       device:(CBPeripheral *)bleduino
                     delegate:(id)delegate
{
    BDWrite *write = [[BDWrite alloc] init];
    write.delegate = delegate;
    
    switch (pipe) {
        case Firmata:
        {
            BDFirmataService *firmata = [[BDFirmataService alloc] initWithPeripheral:bleduino delegate:write];
            [firmata readFirmataCommand];
        }
            break;
        case UART:
        {
            
        }
            break;
        case Notification:
        {
            
        }
            break;
        case BleBridge:
        {
            
        }
            break;
        case Controller:
        {
            
        }
            break;
        case VehicleMotion:
        {
            
        }
            break;
    }
    
    return write;
}

+ (instancetype) subscribePipe:(BlePipe)pipe
                        device:(CBPeripheral *)bleduino
                      delegate:(id)delegate
{
    BDWrite *write = [[BDWrite alloc] init];
    write.delegate = delegate;
    
    switch (pipe) {
        case Firmata:
        {
            BDFirmataService *firmata = [[BDFirmataService alloc] initWithPeripheral:bleduino delegate:write];
            [firmata readFirmataCommand];
        }
            break;
        case UART:
        {
            
        }
            break;
        case Notification:
        {

        }
            break;
        case BleBridge:
        {

        }
            break;
        case Controller:
        {

        }
            break;
        case VehicleMotion:
        {

        }
            break;
    }
    
    return write;
}
@end

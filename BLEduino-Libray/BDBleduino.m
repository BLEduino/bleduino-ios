//
//  BDWrite.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/7/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "BDBleduino.h"
#import "BDBleBridge.h"

@interface BDBleduino ()
@property id delegate;
@end
@implementation BDBleduino


+ (void) writeData:(id)data
              pipe:(BlePipe)pipe
            device:(CBPeripheral *)bleduino
          delegate:(id)delegate
{
    BDBleduino *write = [[BDBleduino alloc] init];
    
    if(pipe == Firmata && [data isKindOfClass:[BDFirmataCommand class]])
    {
        BDFirmataCommand *command = (BDFirmataCommand *)data;
        BDFirmata *firmata = [[BDFirmata alloc] initWithPeripheral:bleduino delegate:write];
        [firmata writeFirmataCommand:command];
    }
    
    switch (pipe) {
        case Firmata:
        {
            BDFirmata *firmata = [[BDFirmata alloc] initWithPeripheral:bleduino delegate:write];
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

+ (void) writeData:(id)data
              pipe:(BlePipe)pipe
            device:(CBPeripheral *)bleduino
{
    [self writeData:data pipe:pipe device:bleduino delegate:nil];
}

+ (instancetype) readDataPipe:(BlePipe)pipe
                       device:(CBPeripheral *)bleduino
                     delegate:(id)delegate
{
    BDBleduino *write = [[BDBleduino alloc] init];
    write.delegate = delegate;
    
    switch (pipe) {
        case Firmata:
        {
            BDFirmata *firmata = [[BDFirmata alloc] initWithPeripheral:bleduino delegate:write];
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
    BDBleduino *write = [[BDBleduino alloc] init];
    write.delegate = delegate;
    
    switch (pipe) {
        case Firmata:
        {
            BDFirmata *firmata = [[BDFirmata alloc] initWithPeripheral:bleduino delegate:write];
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

+ (void) updateDeviceName:(CBPeripheral *)bleduino name:(NSString *)name
{
    /*
     * Work-around for updating the bleduino's name (via BLE-Bridge), because iOS
     * blocks the GAP characteristic for updating the device name.
     */
    
    //Setup data.
    NSMutableData *updateData = [[NSMutableData alloc] initWithCapacity:name.length+1];
    
    //Setup and attache name update command.
    Byte nameByte = (255 >> (0)) & 0xff;
    NSMutableData *nameCmdData = [NSMutableData dataWithBytes:&nameByte length:sizeof(nameByte)];
    [updateData appendData:nameCmdData];
    
    //Setup and attach name.
    NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
    [updateData appendData:nameData];

    //Setup transfer and send update.
    CBUUID *bridge = [CBUUID UUIDWithString:kBleBridgeServiceUUIDString];
    CBUUID *bridgeRx = [CBUUID UUIDWithString:kBridgeRxCharacteristicUUIDString];
    
    BDBleService *gap = [BDBleService serviceWithBleduino:bleduino];
    [gap writeDataToServiceUUID:bridge characteristicUUID:bridgeRx data:updateData withAck:NO];
}

@end

//
//  BDWrite.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/7/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BDFirmata.h"
enum {
    Notification = 0,
    Firmata = 1,
    UART = 2,
    BleBridge = 3,
    Controller = 4,
    VehicleMotion = 5
};
typedef NSUInteger BlePipe;

@interface BDBleduino : NSObject <FirmataServiceDelegate>

+ (void) writeData:(id)data
              pipe:(BlePipe)pipe
            device:(CBPeripheral *)bleduino
          delegate:(id)delegate;

+ (instancetype) readDataPipe:(BlePipe)pipe
                       device:(CBPeripheral *)bleduino
                     delegate:(id)delegate;

+ (instancetype) subscribePipe:(BlePipe)pipe
                        device:(CBPeripheral *)bleduino
                      delegate:(id)delegate;

+ (void) updateDeviceName:(CBPeripheral *)bleduino name:(NSString *)name;

@end

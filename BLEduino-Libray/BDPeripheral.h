//
//  BLEduinoPeripheral.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/10/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BDPeripheral : NSObject
@property (strong) CBPeripheral *bleduino;
@property (strong) NSNumber *RSSI;
@property NSInteger bridgeDeviceID;
@end

//
//  BDProximity.h
//  BLEduino
//
//  Created by Valerie Ann Rodriguez on 8/19/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
enum {
    Immediate = 4,
    VeryNear = 3,
    Near = 2,
    Far = 1,
    VeryFar = 0
};
typedef NSUInteger DistanceRange;

@protocol ProximityDelegate <NSObject>
@required
- (void) bleduino:(CBPeripheral *)bleduino didUpdateValueForRange:(DistanceRange)range
      maxDistance:(NSNumber *)max
      minDistance:(NSNumber *)min
         withRSSI:(NSNumber *)RSSI;

- (void) bleduino:(CBPeripheral *)bleduino didFinishCalibration:(NSNumber *)measuredPower;

@optional
- (void) bleduino:(CBPeripheral *)bleduino didFailToUpdateValueForDistanceWithError:(NSError *)error;
@end

@interface BDProximity : NSObject <CBPeripheralDelegate>
@property (weak) id <ProximityDelegate> delegate;
@property CBPeripheral *monitoredBleduino;
@property float immediateRSSI;
@property float nearRSSI;
@property float farRSSI;
@property float pathLoss; //Path Loss Exponent. 

+ (id)sharedMonitor;
- (void) startMonitoring;
- (void) stopMonitoring;
- (void) startCalibration;
@end

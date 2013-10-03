//
//  ConnectionManager.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol LeDiscoveryManagerDelegate <NSObject>
@optional
//Discovering BLEduino and BLE devices.
- (void) didDiscoverBleduino:(CBPeripheral *)bleduino;
- (void) didDiscoverBleduinos:(NSArray *)bleduinosList;
- (void) didDiscoverBleDevice:(CBPeripheral *)bleDevice;
- (void) didDiscoverBleDevices:(NSArray *)devicesList;

//Connecting to BLEduino and BLE devices.
- (void) didCconnectToBleduino:(CBPeripheral *)bleduino error:(NSError *)error;
- (void) didCconnectToBleduinos:(NSArray *)bleduinosList error:(NSError *)error;
- (void) didCconnectToBleDevice:(CBPeripheral *)bleDevice error:(NSError *)error;
- (void) didCconnectToDevices:(NSArray *)devicesList error:(NSError *)error;

//Disconnecting from BLEduino and BLE devices.
- (void) didDisconnectFromBleduino:(CBPeripheral *)bleduino error:(NSError *)error;
- (void) didDisconnectFromBleduinos:(NSArray *)bleduinosList error:(NSError *)error;
- (void) didDisconnectFromBleDevice:(CBPeripheral *)bleDevice error:(NSError *)error;
- (void) didDisconnectFromDevices:(NSArray *)devicesList error:(NSError *)error;
@end


@interface LeDiscoveryManager : NSObject

@property (nonatomic, assign) id<LeDiscoveryManagerDelegate>    delegate;

/****************************************************************************/
/*					 Access to the devices and services                     */
/****************************************************************************/
@property (retain, nonatomic) NSMutableArray    *foundBleduinos;
@property (retain, nonatomic) NSMutableArray    *connectedBleduinos;
@property (retain, nonatomic) NSMutableArray	*connectedServices;


/****************************************************************************/
/*								Actions										*/
/****************************************************************************/
- (void) startScanningForBleduinos;
- (void) startScanningForBleduinoWithServiceUUIDString:(NSString *)uuidString;
- (void) startScanningForBleduinoWithServicesUUIDStringList:(NSArray *)uuidStringList;
- (void) startScanningForBleduinoWithServiceUUID:(NSUUID *)uuid;
- (void) startScanningForBleduinoWithServicesUUID:(NSArray *)uuidList;

- (void) startScanningForUUIDString:(NSString *)uuidString;
- (void) startScanningForUUID:(NSUUID *)uuid;

- (void) stopScanning;

- (void) connectBleduino:(CBPeripheral *)bleduino;
- (void) connectBleduinos:(NSArray *)bleduinoList;

- (void) disconnectBleduino:(CBPeripheral *)peripheral;
- (void) disconnectBleduinos:(NSArray *)bleduinoList;


/****************************************************************************/
/*				       Access to LeDiscovery instance			     	    */
/****************************************************************************/

+ (id)sharedBleduino;
//+ (id)sharedBleDevice;
//+ (id)sharedBleduino:(id)identifier;
//+ (id)sharedBleDevice:(id)identifier;

@end

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
- (void) didDiscoverBleduino:(CBPeripheral *)bleduino withRSSI:(NSNumber *)RSSI;
- (void) didDiscoverBleduinos:(NSArray *)bleduinosList;
- (void) didDiscoverBleDevice:(CBPeripheral *)bleDevice withRSSI:(NSNumber *)RSSI;
- (void) didDiscoverBleDevices:(NSArray *)devicesList;

//Connecting to BLEduino and BLE devices.
//PENDING: Perhaps all of these should be handled individually.
- (void) didConnectToBleduino:(CBPeripheral *)bleduino;
- (void) didConnectToBleduinos:(NSArray *)bleduinosList;
- (void) didConnectToBleDevice:(CBPeripheral *)bleDevice;
- (void) didConnectToDevices:(NSArray *)devicesList;

- (void) didFailToConnectToBleduino:(CBPeripheral *)bleduino error:(NSError *)error;

//Disconnecting from BLEduino and BLE devices.
- (void) didDisconnectFromBleduino:(CBPeripheral *)bleduino error:(NSError *)error;
- (void) didDisconnectFromBleduinos:(NSArray *)bleduinosList error:(NSError *)error;
- (void) didDisconnectFromBleDevice:(CBPeripheral *)bleDevice error:(NSError *)error;
- (void) didDisconnectFromDevices:(NSArray *)devicesList error:(NSError *)error;
@end

@interface BDLeDiscoveryManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (weak) id <LeDiscoveryManagerDelegate> delegate;

/****************************************************************************/
/*					 Access to the devices and services                     */
/****************************************************************************/

//PENDING: Stretched goal.
//Add support to persist devices.
@property (strong) NSMutableOrderedSet *foundBleduinos;
@property (strong) NSMutableOrderedSet *connectedBleduinos;

//PENDING: Stretched goal.
//Add more context to discovered devices (e.g. RSSI).
@property (strong) NSMutableOrderedSet *bleduinos;


/****************************************************************************/
/*					 Central Manager Settings                               */
/****************************************************************************/
@property (nonatomic, getter = getScanOnlyForBLEduinos) BOOL scanOnlyForBLEduinos;
@property (nonatomic, getter = getNotifyConnect) BOOL notifyConnect;
@property (nonatomic, getter = getNotifyDisconnect) BOOL notifyDisconnect;

/****************************************************************************/
/*								Actions										*/
/****************************************************************************/
- (void) startScanningForBleduinos;
- (void) startScanningForBleduinosWithTimeout:(NSTimeInterval)timeout;
- (void) startScanningForBleDevices;
- (void) startScanning;
- (void) stopScanning;
- (void) connectBleduino:(CBPeripheral *)bleduino;
- (void) disconnectBleduino:(CBPeripheral *)bleduino;

//PENDING: Streached goal. Possible additions.
//- (void) startScanningForBleduinoWithServiceUUIDString:(NSString *)uuidString;
//- (void) startScanningForBleduinoWithServicesUUIDStringList:(NSArray *)uuidStringList;
//- (void) startScanningForBleduinoWithServiceUUID:(NSUUID *)uuid;
//- (void) startScanningForBleduinoWithServicesUUID:(NSArray *)uuidList;
//- (void) startScanningForUUIDString:(NSString *)uuidString;
//- (void) startScanningForUUID:(NSUUID *)uuid;

/****************************************************************************/
/*				       Access to LeDiscovery instance			     	    */
/****************************************************************************/
+ (id)sharedLeManager;
- (void)dismiss;
@end

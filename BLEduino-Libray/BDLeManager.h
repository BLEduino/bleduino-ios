//
//  ConnectionManager.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BDQueue.h"
#import "BDObject.h"

@protocol LeDiscoveryManagerDelegate <NSObject>
//Discovering BLEduino.
@required
- (void) didDiscoverBleduino:(CBPeripheral *)bleduino withRSSI:(NSNumber *)RSSI;
@optional
- (void) didDiscoverBleDevice:(CBPeripheral *)bleDevice withRSSI:(NSNumber *)RSSI;

//Connecting to BLEduino.
@required
- (void) didConnectToBleduino:(CBPeripheral *)bleduino;
- (void) didFailToConnectToBleduino:(CBPeripheral *)bleduino error:(NSError *)error;
@optional
- (void) didFailToAttemptConnectionToBleduino:(CBCentralManagerState)sharedManagerSate;
- (void) didFailToAttemptScannigForBleduinos:(CBCentralManagerState)sharedManagerSate;

//Disconnecting from BLEduino.
@optional
- (void) didDisconnectFromBleduino:(CBPeripheral *)bleduino error:(NSError *)error;

//Updated name.
@optional
- (void) didUpdateBleduinoName:(CBPeripheral *)bleduino;

@end

@interface BDLeManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (weak) id <LeDiscoveryManagerDelegate> delegate;

/****************************************************************************/
/*					 Bleduino Manager Settings                              */
/****************************************************************************/
@property (readonly) BDQueue *bleCommands;
@property (readonly) BDObject *bleduinoDelegate;
@property BOOL isOnlyBleduinoDelegate;

//Enable, so the manager re-connects to bleduinos when disconnected unexpectedly.
@property BOOL isReconnectingEnabled;

/****************************************************************************/
/*					 Access to the devices and services                     */
/****************************************************************************/
@property (strong) NSMutableOrderedSet *foundBleduinos;
@property (strong) NSMutableOrderedSet *connectedBleduinos;
@property (strong) NSMutableOrderedSet *reConnectBleduinos;
@property NSInteger totalServices;

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
- (void) becomeBleduinoDelegate;

/****************************************************************************/
/*				       Access to LeDiscovery instance			     	    */
/****************************************************************************/
+ (id)sharedLeManager;
- (void)dismiss;
@end

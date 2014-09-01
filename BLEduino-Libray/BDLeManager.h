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

@protocol LeManagerDelegate <NSObject>
//Discovering BLEduino.
@required

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void) didDiscoverBleduino:(CBPeripheral *)bleduino withRSSI:(NSNumber *)RSSI;

@optional
- (void) didDiscoverBleDevice:(CBPeripheral *)bleDevice withRSSI:(NSNumber *)RSSI;

//Connecting to BLEduino.
@required

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void) didConnectToBleduino:(CBPeripheral *)bleduino;

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void) didFailToConnectToBleduino:(CBPeripheral *)bleduino error:(NSError *)error;

@optional

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void) didFailToAttemptConnectionToBleduino:(CBCentralManagerState)sharedManagerSate;

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void) didFailToAttemptScannigForBleduinos:(CBCentralManagerState)sharedManagerSate;

//Disconnecting from BLEduino.
@optional
- (void) didDisconnectFromBleduino:(CBPeripheral *)bleduino error:(NSError *)error;

//Updated name.
@optional

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void) didUpdateBleduinoName:(CBPeripheral *)bleduino;

@end

@interface BDLeManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (weak) id <LeManagerDelegate> delegate;

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


/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 *  @see                    startScanningForBleduinos
 *  @see                    startScanningForBleDevices
 *
 */
- (void) startScanning;

/*
 *  @method                 bleduino:delegate:
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
- (void) stopScanning;

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
- (void) connectBleduino:(CBPeripheral *)bleduino;

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
- (void) disconnectBleduino:(CBPeripheral *)bleduino;

- (void) becomeBleduinoDelegate;

/****************************************************************************/
/*				       Access to LeDiscovery instance			     	    */
/****************************************************************************/

/*
 *  @method                 bleduino:delegate:
 *
 *  @param bleudino         UUID for Service to write.
 *  @param delegate         UUID for Characteristic to write.
 *
 *  @discussion             This method requests subscription for notifications and verifies that
 *                          a specific characteristic/service is supported by the peripheral before
 *                          requesting subscription.
 *
 */
+ (id)sharedLeManager;
- (void)dismiss;
@end

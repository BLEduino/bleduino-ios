//
//  BleBridgeService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDObject.h"
#import "BDBleBridge.h"

#pragma mark -
#pragma mark Notification Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BDBridge;
@protocol BridgeDelegate <NSObject>
@required
- (void)didOpenBridge:(BDBridge *)service;
- (void)didFailToOpenBridge:(BDBridge *)service;
@optional
- (void)didFailToKeepBridgeOpen:(BDBridge *)service;
@end

@interface BDBridge : NSObject <CBPeripheralDelegate>
@property BOOL isOpen;

/*
 *  @method                 openBridge
 *
 *  @param aController      The controller that will serve as the delegate for the BDBrige oject. This delegate
 *                          will get notified when and if the ble bridge was opened successful.
 *
 *  @discussion             This method subscribes the iOS device to the BLE Bridge service 
 *                          (Bridge Tx and Bridge RX Characteristic) for each connected BLEduinos. 
 *                          Then listens to incoming data, upon reciving data the iOS device then
 *                          relays the data to the corresponsing BLEduino.
 *
 */
- (void)openBridgeWithDelegate:(id <BridgeDelegate>)aController;

/*
 *  @method                 closeBridge
 *
 *  @discussion             This method unsubscribes the iOS device from the BDBridge service for
 *                          each connected BLEduino. That is, stops listening altogether.
 *
 */
- (void)closeBridge;

/****************************************************************************/
/*				       Access to Ble Bridge instance			     	    */
/****************************************************************************/
+ (BDBridge *)sharedBridge;

@end

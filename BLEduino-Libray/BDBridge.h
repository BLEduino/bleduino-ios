//
//  BleBridgeService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDObject.h"
#import "BDBleBridgeService.h"

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

@interface BDBridge : BDObject <CBPeripheralDelegate>
@property BOOL isOpen;

/*
 *  @method                 openBridge
 *
 *  @discussion             This method subscribes the iOS device to the BLE Bridge service for
 *                          all connected BLEduinos. Then listens to incoming data, upon reciving
 *                          data the iOS device then relays the data to the corresponsing BLEduino.
 *
 */
- (void)openBridgeForDelegate:(id <BridgeDelegate>)aController;

/*
 *  @method                 closeBridge
 *
 *  @discussion             This method unsubscribes the iOS device from the BLE Bridge service for
 *                          all connected BLEduinos. That is, stops listening altogether.
 *
 */
- (void)closeBridgeForDelegate:(id <BridgeDelegate>)aController;

/****************************************************************************/
/*				       Access to Ble Bridge instance			     	    */
/****************************************************************************/
+ (BDBridge *)sharedBridge;

@end

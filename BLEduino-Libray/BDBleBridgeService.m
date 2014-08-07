//
//  BleBridgeService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDBleBridgeService.h"
#import "BDLeDiscoveryManager.h"
#import "BDPeripheral.h"

#pragma mark -
#pragma mark BLE Bridge Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString * const kBleBridgeServiceUUIDString = @"8C6BB1EB-A312-681D-025B-0032C0D16A2D";
NSString * const kBridgeRxCharacteristicUUIDString = @"8C6B5778-A312-681D-025B-0032C0D16A2D";
NSString * const kBridgeTxCharacteristicUUIDString = @"8C6B454B-A312-681D-025B-0032C0D16A2D";
NSString * const kDeviceIDCharacteristicUUIDString = @"8C6BD1D0-A312-681D-025B-0032C0D16A2D";

#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*								Setup										*/
/****************************************************************************/
@interface BDBleBridgeService ()
@property (strong) CBUUID *bleBridgeServiceUUID;
@property (strong) CBUUID *bridgeRxCharacteristicUUID;
@property (strong) CBUUID *bridgeTxCharacteristicUUID;
@property (strong) CBUUID *deviceIDCharacteristicUUID;
@property (strong) NSMutableOrderedSet *bridges;
@property (strong) NSMutableDictionary *deviceIDs;
@property (strong) NSMutableDictionary *verifyDeviceIDs;
@property (weak) id <BleBridgeServiceDelegate> delegate;
@property BOOL bridgedOpenedSuccesfuly;
@property NSInteger totalBridges;
@property NSInteger totalIDs;
@property NSInteger deviceID;
@end

@implementation BDBleBridgeService

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<BleBridgeServiceDelegate>)aController
       peripheralDelegate:(id<CBPeripheralDelegate>)delegate;
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = delegate;
		self.delegate = aController;
        
        self.bleBridgeServiceUUID = [CBUUID UUIDWithString:kBleBridgeServiceUUIDString];
        self.bridgeRxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeRxCharacteristicUUIDString];
        self.bridgeTxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString];
        self.deviceIDCharacteristicUUID = [CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString];
    }
    
    return self;
}

+ (BDBleBridgeService *)sharedBridge
{
    static id sharedBleBridge = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBleBridge = [[[self class] alloc] init];
    });
    return sharedBleBridge;
}

/*
 *  @method                 openBridge
 *
 *  @discussion             This method subscribes the iOS device to the BLE Bridge service for
 *                          all connected BLEduinos. Then listens to incoming data, upon reciving
 *                          data the iOS device then relays the data to the corresponsing BLEduino.
 *
 */
- (void)openBridgeForDelegate:(id<BleBridgeServiceDelegate>)aController
{
    //Open bridge only if there is not one already opened.
    if(!self.isOpen)
    {
        self.isOpen = YES; //bridge is open.
        BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
        self.totalBridges = leManager.connectedBleduinos.count;
        self.totalIDs = self.totalBridges;
        
        //Setup bridges and device IDs.
        self.bridges = [[NSMutableOrderedSet alloc] initWithCapacity:self.totalBridges];
        self.deviceIDs = [[NSMutableDictionary alloc] initWithCapacity:self.totalBridges];
        
        for(CBPeripheral *bleduino in leManager.connectedBleduinos)
        {
            BDBleBridgeService *bridge = [[BDBleBridgeService alloc] initWithPeripheral:bleduino
                                                                               delegate:nil
                                                                     peripheralDelegate:self];
            bridge.isOpen = YES;
            
            [self.bridges addObject:bridge];
            
            //Read the deviceID.
            [bridge readDataFromServiceUUID:bridge.bleBridgeServiceUUID characteristicUUID:bridge.deviceIDCharacteristicUUID];
        }
        
        [self performSelector:@selector(didBridgeOpen) withObject:nil afterDelay:30];
        NSLog(@"BLE-Bridge: bridge is open.");
    }
}

/*
 *  @method                 closeBridge
 *
 *  @discussion             This method unsubscribes the iOS device from the BLE Bridge service for
 *                          all connected BLEduinos. That is, stops listening altogether.
 *
 */
- (void)closeBridgeForDelegate:(id<BleBridgeServiceDelegate>)aController
{
    for(BDBleBridgeService *bridge in self.bridges)
    {
        [bridge setNotificationForServiceUUID:bridge.bleBridgeServiceUUID
                           characteristicUUID:bridge.bridgeTxCharacteristicUUID
                                  notifyValue:NO];
    }
    
    //Remove all BLEduinos.
    [self.bridges removeAllObjects];
    
    self.isOpen = NO;
    self.bridgedOpenedSuccesfuly = NO;
    
    NSLog(@"BLE-Bridge: bridge is closed.");
}

#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //Did get unique device ID?
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString]] &&
       [self.deviceIDs objectForKey:[peripheral.identifier UUIDString]] == nil)
    {
        //Convert deviceID data to integer.
        Byte *deviceIDByte = (Byte*)malloc(1);
        NSRange deviceIDRange = NSMakeRange(0, 1);
        [characteristic.value getBytes:deviceIDByte range:deviceIDRange];
        NSData *deviceIDData = [[NSData alloc] initWithBytes:deviceIDByte length:1];
        int deviceID = *(int*)([deviceIDData bytes]);
    
        //Store deviceID
        [self.deviceIDs setObject:[NSNumber numberWithInt:deviceID] forKey:[peripheral.identifier UUIDString]];
        self.totalIDs = self.totalIDs - 1;
        
        //Do we have the device ID for all bleduinos?
        if(self.totalIDs == 0)
        {
            self.verifyDeviceIDs = [[NSMutableDictionary alloc] initWithDictionary:self.deviceIDs copyItems:YES];
            
            //Found all deviceIDs, now subscribe to recive data from all bleduinos.
            for(BDBleBridgeService *bridge in self.bridges)
            {
                //Store deviceID on the corresponding service.
                NSString *peripheralUUID = [bridge.peripheral.identifier UUIDString];
                bridge.deviceID = [((NSNumber *)[self.deviceIDs objectForKey:peripheralUUID]) integerValue];
                
                [bridge setNotificationForServiceUUID:bridge.bleBridgeServiceUUID
                                   characteristicUUID:bridge.bridgeTxCharacteristicUUID
                                          notifyValue:YES];
            }
        }
    }
    else
    {
        //Find deviceID for destination device.
        Byte *deviceIDByte = (Byte*)malloc(1);
        NSRange deviceIDRange = NSMakeRange(0, 1);
        [characteristic.value getBytes:deviceIDByte range:deviceIDRange];
        NSData *deviceIDData = [[NSData alloc] initWithBytes:deviceIDByte length:1];
        int deviceID = *(int*)([deviceIDData bytes]);
        
        NSLog(@"Total Bytes: %ld", (long)[characteristic.value length]);
        
        //Find destination device.
        for(BDBleBridgeService *bridge in self.bridges)
        {
            //Found destination device. Relay message.
            if(bridge.deviceID == deviceID)
            {
                [bridge writeDataToServiceUUID:bridge.bleBridgeServiceUUID
                            characteristicUUID:bridge.bridgeRxCharacteristicUUID
                                          data:characteristic.value
                                       withAck:NO];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    NSArray *peripheralUUIDs = [self.verifyDeviceIDs allKeys];
    
    //Did subscribed to unique Bridges TXs?
    if([peripheralUUIDs containsObject:[peripheral.identifier UUIDString]] &&
       [characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString]] &&
       characteristic.isNotifying)
    {
        //Remove peripheral.
        [self.verifyDeviceIDs removeObjectForKey:[peripheral.identifier UUIDString]];
        self.totalBridges = self.totalBridges - 1;
        
        //Did bridge opened succesfuly?
        if(self.totalBridges == 0)
        {
            self.bridgedOpenedSuccesfuly = YES;
            if([self.delegate respondsToSelector:@selector(didOpenBridge:)])
            {
                [self.delegate didOpenBridge:self];
            }
        }
    }
}

- (void)didBridgeOpen
{
    if(!self.bridgedOpenedSuccesfuly)
    {
        [self.delegate didFailToOpenBridge:self];
    }
}
@end

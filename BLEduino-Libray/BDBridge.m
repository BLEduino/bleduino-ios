//
//  BleBridgeService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDBridge.h"
#import "BDLeManager.h"
#import "BDBleBridge.h"

#pragma mark -
#pragma mark - Private Class
/****************************************************************************/
/*								Bridge										*/
/****************************************************************************/
@interface Bridge : BDObject
@property (strong) CBUUID *bleBridgeServiceUUID;
@property (strong) CBUUID *bridgeRxCharacteristicUUID;
@property (strong) CBUUID *bridgeTxCharacteristicUUID;
@property (strong) CBUUID *deviceIDCharacteristicUUID;
@property NSInteger deviceID;
@end

@implementation Bridge

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<CBPeripheralDelegate>)delegate
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        
        //Should this object be the peripheral's delagate, or are we using the global delegate?
        BDLeManager *manager = [BDLeManager sharedLeManager];
        if(!manager.isOnlyBleduinoDelegate) _servicePeripheral.delegate = delegate;
        
        self.bleBridgeServiceUUID = [CBUUID UUIDWithString:kBleBridgeServiceUUIDString];
        self.bridgeRxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeRxCharacteristicUUIDString];
        self.bridgeTxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString];
        self.deviceIDCharacteristicUUID = [CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString];
    }
    
    return self;
}
@end

#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*								Setup										*/
/****************************************************************************/
@interface BDBridge ()
@property (strong) NSMutableOrderedSet *bridges;
@property (strong) NSMutableDictionary *deviceIDs;
@property (strong) NSMutableDictionary *verifyDeviceIDs;
@property BOOL bridgedOpenedSuccesfuly;
@property NSInteger totalBridges;
@property NSInteger totalIDs;

@property (weak) id <BridgeDelegate> delegate;
@end

@implementation BDBridge

+ (BDBridge *)sharedBridge
{
    static id sharedBleBridge = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBleBridge = [[[self class] alloc] init];
    });
    return sharedBleBridge;
}

- (id)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didUpdateValue:) name:CHARACTERISTIC_UPDATE_BLE_BRIDGE_DEVICE_ID object:nil];
        [center addObserver:self selector:@selector(didUpdateValue:) name:CHARACTERISTIC_UPDATE_BLE_BRIDGE_TX object:nil];
        
        [center addObserver:self selector:@selector(didNotifyUpdate:) name:CHARACTERISTIC_NOTIFY_BLE_BRIDGE_DEVICE_ID object:nil];
        [center addObserver:self selector:@selector(didNotifyUpdate:) name:CHARACTERISTIC_NOTIFY_BLE_BRIDGE_TX object:nil];
    }
    return self;
}

/*
 *  @method                 openBridge
 *
 *  @discussion             This method subscribes the iOS device to the BLE Bridge service for
 *                          all connected BLEduinos. Then listens to incoming data, upon reciving
 *                          data the iOS device then relays the data to the corresponsing BLEduino.
 *
 */
- (void)openBridgeWithDelegate:(id<BridgeDelegate>)aController
{
    //Open bridge only if there is not one already opened.
    if(!self.isOpen)
    {
        self.isOpen = YES; //bridge is open.
        self.delegate = aController;
        
        BDLeManager *leManager = [BDLeManager sharedLeManager];
        self.totalBridges = leManager.connectedBleduinos.count;
        self.totalIDs = self.totalBridges;
        
        //Setup bridges and device IDs.
        self.bridges = [[NSMutableOrderedSet alloc] initWithCapacity:self.totalBridges];
        self.deviceIDs = [[NSMutableDictionary alloc] initWithCapacity:self.totalBridges];
        
        for(CBPeripheral *bleduino in leManager.connectedBleduinos)
        {
            Bridge *bridge = [[Bridge alloc] initWithPeripheral:bleduino
                                                       delegate:self];
            
            [self.bridges addObject:bridge];
            
            //Read the deviceID.
            [bridge readDataFromServiceUUID:bridge.bleBridgeServiceUUID characteristicUUID:bridge.deviceIDCharacteristicUUID];
        }
        
        [self performSelector:@selector(didBridgeOpen) withObject:nil afterDelay:5];
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
- (void)closeBridge
{
    for(Bridge *bridge in self.bridges)
    {
        [bridge dismissPeripheral];
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
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [BDObject peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error && ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString]] ||
                 [characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString]]))
    {
        [self closeBridge];
        if(self.bridgedOpenedSuccesfuly)
        {
            if([self.delegate respondsToSelector:@selector(didFailToKeepBridgeOpen:)])
            {
                [self.delegate didFailToKeepBridgeOpen:self];
            }
        }
        else
        {
            [self.delegate didFailToOpenBridge:self];
        }
    }
    else
    {
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString]] ||
           [characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString]])
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
                free(deviceIDByte);
                
                //Store deviceID
                [self.deviceIDs setObject:[NSNumber numberWithInt:deviceID] forKey:[peripheral.identifier UUIDString]];
                self.totalIDs = self.totalIDs - 1;
                
                //Do we have the device ID for all bleduinos?
                if(self.totalIDs == 0)
                {
                    self.verifyDeviceIDs = [[NSMutableDictionary alloc] initWithDictionary:self.deviceIDs copyItems:YES];
                    
                    //Found all deviceIDs, now subscribe to recive data from all bleduinos.
                    for(Bridge *bridge in self.bridges)
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
                free(deviceIDByte);
                
                NSLog(@"Total Bytes: %ld", (long)[characteristic.value length]);
                
                //Update payload with the sender's deviceID.
                NSMutableData *updatedPayload = [[NSMutableData alloc] initWithCapacity:characteristic.value.length];
                
                //Collect and store the sender's deviceID.
                NSInteger senderDeviceID = [((NSNumber *)[self.deviceIDs objectForKey:[peripheral.identifier UUIDString]]) integerValue];
                Byte senderDeviceIDByte = (senderDeviceID >> (0)) & 0xff;
                NSMutableData *senderDeviceIDData = [NSMutableData dataWithBytes:&senderDeviceIDByte length:sizeof(senderDeviceIDByte)];
                [updatedPayload appendData:senderDeviceIDData];
                
                //Complete payload.
                NSUInteger payloadLength = characteristic.value.length - 1;
                NSData *payload = [characteristic.value subdataWithRange:NSMakeRange(1, payloadLength)];
                [updatedPayload appendData:payload];
                
                //Find destination device.
                for(Bridge *bridge in self.bridges)
                {
                    //Found destination device. Relay message.
                    if(bridge.deviceID == deviceID)
                    {
                        [bridge writeDataToServiceUUID:bridge.bleBridgeServiceUUID
                                    characteristicUUID:bridge.bridgeRxCharacteristicUUID
                                                  data:updatedPayload
                                               withAck:NO];
                    }
                }
            }
        }
        else
        {
            [BDObject peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if(error && [characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString]])
    {
        [self closeBridge];
        if(self.bridgedOpenedSuccesfuly)
        {
            if([self.delegate respondsToSelector:@selector(didFailToKeepBridgeOpen:)])
            {
                [self.delegate didFailToKeepBridgeOpen:self];
            }
        }
        else
        {
            [self.delegate didFailToOpenBridge:self];
        }
    }
    else
    {
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString]])
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
        else
        {
            [BDObject peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
        }
    }
}

- (void)didBridgeOpen
{
    if(!self.bridgedOpenedSuccesfuly && self.isOpen)
    {
        [self.delegate didFailToOpenBridge:self];
    }
}

#pragma mark -
#pragma mark - Peripheral Delegate Gateways
/****************************************************************************/
/*				       Peripheral Delegate Gateways                         */
/****************************************************************************/
- (void)didUpdateValue:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    NSArray *identifiers = [self.deviceIDs allKeys];
    if([identifiers containsObject:peripheral.identifier])
    {
        if(error)
        {
            [self closeBridge];
            if(self.bridgedOpenedSuccesfuly)
            {
                if([self.delegate respondsToSelector:@selector(didFailToKeepBridgeOpen:)])
                {
                    [self.delegate didFailToKeepBridgeOpen:self];
                }
            }
            else
            {
                [self.delegate didFailToOpenBridge:self];
            }
        }
        else
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
                free(deviceIDByte);
                
                //Store deviceID
                [self.deviceIDs setObject:[NSNumber numberWithInt:deviceID] forKey:[peripheral.identifier UUIDString]];
                self.totalIDs = self.totalIDs - 1;
                
                //Do we have the device ID for all bleduinos?
                if(self.totalIDs == 0)
                {
                    self.verifyDeviceIDs = [[NSMutableDictionary alloc] initWithDictionary:self.deviceIDs copyItems:YES];
                    
                    //Found all deviceIDs, now subscribe to recive data from all bleduinos.
                    for(Bridge *bridge in self.bridges)
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
                free(deviceIDByte);
                
                NSLog(@"Total Bytes: %ld", (long)[characteristic.value length]);
                
                //Update payload with the sender's deviceID.
                NSMutableData *updatedPayload = [[NSMutableData alloc] initWithCapacity:characteristic.value.length];
                
                //Collect and store the sender's deviceID.
                NSInteger senderDeviceID = [((NSNumber *)[self.deviceIDs objectForKey:[peripheral.identifier UUIDString]]) integerValue];
                Byte senderDeviceIDByte = (senderDeviceID >> (0)) & 0xff;
                NSMutableData *senderDeviceIDData = [NSMutableData dataWithBytes:&senderDeviceIDByte length:sizeof(senderDeviceIDByte)];
                [updatedPayload appendData:senderDeviceIDData];
                
                //Complete payload.
                NSUInteger payloadLength = characteristic.value.length - 1;
                NSData *payload = [characteristic.value subdataWithRange:NSMakeRange(1, payloadLength)];
                [updatedPayload appendData:payload];
                
                //Find destination device.
                for(Bridge *bridge in self.bridges)
                {
                    //Found destination device. Relay message.
                    if(bridge.deviceID == deviceID)
                    {
                        [bridge writeDataToServiceUUID:bridge.bleBridgeServiceUUID
                                    characteristicUUID:bridge.bridgeRxCharacteristicUUID
                                                  data:updatedPayload
                                               withAck:NO];
                    }
                }
            }
        }
    }
}

- (void)didNotifyUpdate:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];

    NSArray *identifiers = [self.deviceIDs allKeys];
    if([identifiers containsObject:peripheral.identifier])
    {
        if(error)
        {
            [self closeBridge];
            if(self.bridgedOpenedSuccesfuly)
            {
                if([self.delegate respondsToSelector:@selector(didFailToKeepBridgeOpen:)])
                {
                    [self.delegate didFailToKeepBridgeOpen:self];
                }
            }
            else
            {
                [self.delegate didFailToOpenBridge:self];
            }
        }
        else
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
    }
}

@end

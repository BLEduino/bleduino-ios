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

@interface BDBleBridgeService ()
@property (strong) CBUUID *bleBridgeServiceUUID;
@property (strong) CBUUID *bridgeRxCharacteristicUUID;
@property (strong) CBUUID *bridgeTxCharacteristicUUID;
@property (strong) CBUUID *deviceIDCharacteristicUUID;
@property (strong) NSMutableOrderedSet *servicePeripherals;
@end

@implementation BDBleBridgeService

- (id) init
{
    self = [super init];
    if (self) {    
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
- (void)openBridge
{
    self.isOpen = YES;
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    self.servicePeripherals = [[NSMutableOrderedSet alloc] initWithCapacity:leManager.connectedBleduinos.count];

    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        CBPeripheral *bleduinoPeripheral = [bleduino copy];
        bleduinoPeripheral.delegate = self;
        
        BDPeripheral *device = [[BDPeripheral alloc] init];
        device.bleduino = bleduinoPeripheral;
        
        [self.servicePeripherals addObject:device];
        
        [self readDataFromServiceUUID:self.bleBridgeServiceUUID
                   characteristicUUID:self.deviceIDCharacteristicUUID];
    }
    
    NSLog(@"BLE-Bridge: bridge is open.");
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
    for(BDPeripheral *device in self.servicePeripherals)
    {
        [self setNotificationForServiceUUID:self.bleBridgeServiceUUID
                         characteristicUUID:self.bridgeTxCharacteristicUUID
                                notifyValue:NO];
    }
    
    //Remove all BLEduinos.
    [self.servicePeripherals removeAllObjects];
    
    self.isOpen = NO;
    
    NSLog(@"BLE-Bridge: bridge is closed.");
}

#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:self.deviceIDCharacteristicUUID])
    {
        //Convert deviceID data to integer.
        Byte *deviceIDByte = (Byte*)malloc(1);
        NSRange deviceIDRange = NSMakeRange(0, 1);
        [characteristic.value getBytes:deviceIDByte range:deviceIDRange];
        NSData *deviceIDData = [[NSData alloc] initWithBytes:deviceIDByte length:1];
        int deviceID = *(int*)([deviceIDData bytes]);
        
        //Store deviceID.
        for(BDPeripheral *device in self.servicePeripherals)
        {
            if([device.bleduino.identifier isEqual:peripheral.identifier])
            {
                device.bridgeDeviceID = deviceID;
            }
        }
        
        //Found deviceID, now subscribe to recive data from this bleduino.
        [self setNotificationForServiceUUID:self.bleBridgeServiceUUID
                         characteristicUUID:self.bridgeTxCharacteristicUUID
                                notifyValue:YES];
    }
    else
    {
        //Find deviceID for destination device.
        Byte *deviceIDByte = (Byte*)malloc(1);
        NSRange deviceIDRange = NSMakeRange(1, 1);
        [characteristic.value getBytes:deviceIDByte range:deviceIDRange];
        NSData *deviceIDData = [[NSData alloc] initWithBytes:deviceIDByte length:1];
        int deviceID = *(int*)([deviceIDData bytes]);
        
        //Find destination device.
        for(BDPeripheral *device in self.servicePeripherals)
        {
            //Found destination device. Relay message.
            if(device.bridgeDeviceID == deviceID)
            {
                [self writeDataToServiceUUID:self.bleBridgeServiceUUID
                          characteristicUUID:self.bridgeRxCharacteristicUUID
                                        data:characteristic.value
                                     withAck:NO];
            }
        }
    }
}
@end

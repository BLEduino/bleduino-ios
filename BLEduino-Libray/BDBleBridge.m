//
//  BDBleBridgeService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/25/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "BDBleBridge.h"
#import "BDLeManager.h"

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
@interface BDBleBridge ()
@property (strong) CBUUID *bleBridgeServiceUUID;
@property (strong) CBUUID *bridgeRxCharacteristicUUID;
@property (strong) CBUUID *bridgeTxCharacteristicUUID;
@property (strong) CBUUID *deviceIDCharacteristicUUID;
@property (weak) id <BleBridgeServiceDelegate> delegate;
@end

@implementation BDBleBridge

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<BleBridgeServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
		self.delegate = aController;
        
        //Should this object be the peripheral's delagate, or are we using the global delegate?
        BDLeManager *manager = [BDLeManager sharedLeManager];
        if(!manager.isOnlyBleduinoDelegate) _servicePeripheral.delegate = self;
        
        self.bleBridgeServiceUUID = [CBUUID UUIDWithString:kBleBridgeServiceUUIDString];
        self.bridgeRxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeRxCharacteristicUUIDString];
        self.bridgeTxCharacteristicUUID = [CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString];
        self.deviceIDCharacteristicUUID = [CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didWriteValue:) name:CHARACTERISTIC_WRITE_ACK_BLE_BRIDGE_DEVICE_ID object:nil];
        [center addObserver:self selector:@selector(didWriteValue:) name:CHARACTERISTIC_WRITE_ACK_BLE_BRIDGE_RX object:nil];
        
        [center addObserver:self selector:@selector(didUpdateValue:) name:CHARACTERISTIC_UPDATE_BLE_BRIDGE_DEVICE_ID object:nil];
        [center addObserver:self selector:@selector(didUpdateValue:) name:CHARACTERISTIC_UPDATE_BLE_BRIDGE_TX object:nil];
        
        [center addObserver:self selector:@selector(didNotifyUpdate:) name:CHARACTERISTIC_NOTIFY_BLE_BRIDGE_DEVICE_ID object:nil];
        [center addObserver:self selector:@selector(didNotifyUpdate:) name:CHARACTERISTIC_NOTIFY_BLE_BRIDGE_TX object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark Writing to BLEduino
// Writing data to BLEduino.
- (void) writeDeviceID:(NSInteger)deviceID withAck:(BOOL)enabled;
{
    Byte deviceIdByte = (self.deviceID >> (0)) & 0xff;
    NSMutableData *deviceIdData = [NSMutableData dataWithBytes:&deviceIdByte length:sizeof(deviceIdByte)];
    
    [self writeDataToServiceUUID:self.bleBridgeServiceUUID
              characteristicUUID:self.deviceIDCharacteristicUUID
                            data:deviceIdData
                         withAck:enabled];
}

- (void) writeDeviceID:(NSInteger)deviceID
{
    self.deviceID = deviceID;
    [self writeDeviceID:deviceID withAck:NO];
}

- (void) writeData:(NSData *)data withAck:(BOOL)enabled
{
    [self writeDataToServiceUUID:self.bleBridgeServiceUUID
              characteristicUUID:self.bridgeRxCharacteristicUUID
                            data:data
                         withAck:enabled];
}

- (void) writeData:(NSData *)data
{
    self.dataSent = data;
    [self writeData:data withAck:NO];
}

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving data from BLEduino.
- (void) readDeviceID
{
    [self readDataFromServiceUUID:self.bleBridgeServiceUUID
               characteristicUUID:self.deviceIDCharacteristicUUID];
}

- (void) readData
{
    [self readDataFromServiceUUID:self.bleBridgeServiceUUID
               characteristicUUID:self.bridgeTxCharacteristicUUID];
}

- (void) subscribeToStartReceivingBridgeData
{
    [self setNotificationForServiceUUID:self.bleBridgeServiceUUID
                     characteristicUUID:self.bridgeTxCharacteristicUUID
                            notifyValue:YES];
}

- (void) unsubscribeToStopReiceivingBridgeData
{
    [self setNotificationForServiceUUID:self.bleBridgeServiceUUID
                     characteristicUUID:self.bridgeTxCharacteristicUUID
                            notifyValue:NO];
}

#pragma mark -
#pragma mark - Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeRxCharacteristicUUIDString ]])
    {
        if([self.delegate respondsToSelector:@selector(bridgeService:didWriteData:error:)])
        {
            [self.delegate bridgeService:self didWriteData:characteristic.value error:error];
        }
    }
    else
    {
        [BDObject peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString ]])
    {
        self.dataReceived = characteristic.value;
        if([self.delegate respondsToSelector:@selector(bridgeService:didReceiveData:error:)])
        {
            [self.delegate bridgeService:self didReceiveData:characteristic.value error:error];
        }
    }
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString ]])
    {
        //Get deviceID
        Byte *deviceIdByte = (Byte*)malloc(1);
        NSRange deviceIdRange = NSMakeRange(0, 1);
        [characteristic.value getBytes:deviceIdByte range:deviceIdRange];
        NSData *deviceIdData = [[NSData alloc] initWithBytes:deviceIdByte length:1];
        self.deviceID = *(int*)([deviceIdData bytes]);
        free(deviceIdByte);
        
        if([self.delegate respondsToSelector:@selector(bridgeService:didReceiveDeviceID:error:)])
        {
            [self.delegate bridgeService:self didReceiveDeviceID:self.deviceID error:error];
        }
    }
    else
    {
        [BDObject peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString]])
    {
        if(characteristic.isNotifying)
        {
            if([self.delegate respondsToSelector:@selector(didSubscribeToReceiveBridgeMessagesFor:error:)])
            {
                [self.delegate didSubscribeToReceiveBridgeMessagesFor:self error:error];
            }
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(didUnsubscribeToReceiveBridgeMessagesFor:error:)])
            {
                [self.delegate didUnsubscribeToReceiveBridgeMessagesFor:self error:error];
            }
        }
    }
    else
    {
        [BDObject peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
}


#pragma mark -
#pragma mark - Peripheral Delegate Gateways
/****************************************************************************/
/*				       Peripheral Delegate Gateways                         */
/****************************************************************************/
- (void)didWriteValue:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if([peripheral.identifier isEqual:_servicePeripheral.identifier])
    {
        if([self.delegate respondsToSelector:@selector(bridgeService:didWriteData:error:)])
        {
            [self.delegate bridgeService:self didWriteData:characteristic.value error:error];
        }
    }
}

- (void)didUpdateValue:(NSNotification *)notification
{
    NSDictionary *payload = notification.userInfo;
    CBCharacteristic *characteristic = [payload objectForKey:@"Characteristic"];
    CBPeripheral *peripheral = [payload objectForKey:@"Peripheral"];
    NSError *error = [payload objectForKey:@"Error"];
    
    if([peripheral.identifier isEqual:_servicePeripheral.identifier])
    {
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kBridgeTxCharacteristicUUIDString ]])
        {
            self.dataReceived = characteristic.value;
            if([self.delegate respondsToSelector:@selector(bridgeService:didReceiveData:error:)])
            {
                [self.delegate bridgeService:self didReceiveData:characteristic.value error:error];
            }
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceIDCharacteristicUUIDString ]])
        {
            //Get deviceID
            Byte *deviceIdByte = (Byte*)malloc(1);
            NSRange deviceIdRange = NSMakeRange(0, 1);
            [characteristic.value getBytes:deviceIdByte range:deviceIdRange];
            NSData *deviceIdData = [[NSData alloc] initWithBytes:deviceIdByte length:1];
            self.deviceID = *(int*)([deviceIdData bytes]);
            free(deviceIdByte);
            
            if([self.delegate respondsToSelector:@selector(bridgeService:didReceiveDeviceID:error:)])
            {
                [self.delegate bridgeService:self didReceiveDeviceID:self.deviceID error:error];
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
    
    if([peripheral.identifier isEqual:_servicePeripheral.identifier])
    {
        if(characteristic.isNotifying)
        {
            if([self.delegate respondsToSelector:@selector(didSubscribeToReceiveBridgeMessagesFor:error:)])
            {
                [self.delegate didSubscribeToReceiveBridgeMessagesFor:self error:error];
            }
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(didUnsubscribeToReceiveBridgeMessagesFor:error:)])
            {
                [self.delegate didUnsubscribeToReceiveBridgeMessagesFor:self error:error];
            }
        }
    }
}
@end

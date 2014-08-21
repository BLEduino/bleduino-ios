//
//  ControllerService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDController.h"

#pragma mark -
#pragma mark Controller Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString * const kControllerServiceUUIDString = @"8C6BF001-A312-681D-025B-0032C0D16A2D";
NSString * const kButtonActionCharacteristicUUIDString = @"8C6BD00D-A312-681D-025B-0032C0D16A2D";

#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*								Setup										*/
/****************************************************************************/
@interface BDController ()
@property (strong) CBUUID *controllerServiceUUID;
@property (strong) CBUUID *buttonActionCharacteristicUUID;

@property (weak) id <ControllerServiceDelegate> delegate;
@property (strong) BDButtonAction *lastSentButtonAction;
@end
@implementation BDController

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<ControllerServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = self;
		self.delegate = aController;
        
        self.controllerServiceUUID = [CBUUID UUIDWithString:kControllerServiceUUIDString];
        self.buttonActionCharacteristicUUID = [CBUUID UUIDWithString:kButtonActionCharacteristicUUIDString];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didWriteValue:) name:CHARACTERISTIC_WRITE_ACK_CONTROLLER object:nil];
        [center addObserver:self selector:@selector(didUpdateValue:) name:CHARACTERISTIC_UPDATE_CONTROLLER object:nil];
        [center addObserver:self selector:@selector(didNotifyUpdate:) name:CHARACTERISTIC_NOTIFY_CONTROLLER object:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark Writing to BLEduino
/****************************************************************************/
/*				      Write button action to BLEduino                       */
/****************************************************************************/
- (void) writeButtonAction:(BDButtonAction *)buttonAction
                   withAck:(BOOL)enabled
{
    self.lastSentButtonAction = buttonAction;
    [self writeDataToServiceUUID:self.controllerServiceUUID
              characteristicUUID:self.buttonActionCharacteristicUUID
                            data:[buttonAction data]
                         withAck:enabled];
}

- (void) writeButtonAction:(BDButtonAction *)buttonAction
{
    self.lastButtonAction = buttonAction;
    [self writeButtonAction:buttonAction withAck:NO];
}

#pragma mark -
#pragma mark Reading from BLEduino
/****************************************************************************/
/*				      Read button action from BLEduino                      */
/****************************************************************************/
- (void) readButtonAction
{
    [self readDataFromServiceUUID:self.controllerServiceUUID
               characteristicUUID:self.buttonActionCharacteristicUUID];
}

- (void) subscribeToStartReceivingButtonActions
{
    [self setNotificationForServiceUUID:self.controllerServiceUUID
                     characteristicUUID:self.buttonActionCharacteristicUUID
                            notifyValue:YES];
}

- (void) unsubscribeToStopReiceivingButtonActions
{
    [self setNotificationForServiceUUID:self.controllerServiceUUID
                     characteristicUUID:self.buttonActionCharacteristicUUID
                            notifyValue:NO];
}

#pragma mark -
#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kButtonActionCharacteristicUUIDString]])
    {
        self.lastButtonAction = self.lastSentButtonAction;
        if([self.delegate respondsToSelector:@selector(controllerService:didWriteButtonAction:error:)])
        {
            [self.delegate controllerService:self
                        didWriteButtonAction:self.lastButtonAction
                                       error:error];
        }
    }
    else
    {
        [BDBleService peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kButtonActionCharacteristicUUIDString]])
    {
        self.lastButtonAction = [[BDButtonAction alloc] initWithData:characteristic.value];
        if([self.delegate respondsToSelector:@selector(controllerService:didReceiveButtonAction:error:)])
        {
            [self.delegate controllerService:self
                      didReceiveButtonAction:self.lastButtonAction
                                       error:error];
        }
    }
    else
    {
        [BDBleService peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kButtonActionCharacteristicUUIDString]])
    {
        if(characteristic.isNotifying)
        {
            if([self.delegate respondsToSelector:@selector(didSubscribeToStartReceivingButtonActionsFor:error:)])
            {
                [self.delegate didSubscribeToStartReceivingButtonActionsFor:self error:error];
            }
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(didUnsubscribeToStopRecivingButtonActionsFor:error:)])
            {
                [self.delegate didUnsubscribeToStopRecivingButtonActionsFor:self error:error];
            }
        }
    }
    else
    {
        [BDBleService peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
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
        self.lastButtonAction = self.lastSentButtonAction;
        if([self.delegate respondsToSelector:@selector(controllerService:didWriteButtonAction:error:)])
        {
            [self.delegate controllerService:self
                        didWriteButtonAction:self.lastButtonAction
                                       error:error];
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
        self.lastButtonAction = [[BDButtonAction alloc] initWithData:characteristic.value];
        if([self.delegate respondsToSelector:@selector(controllerService:didReceiveButtonAction:error:)])
        {
            [self.delegate controllerService:self
                      didReceiveButtonAction:self.lastButtonAction
                                       error:error];
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
            if([self.delegate respondsToSelector:@selector(didSubscribeToStartReceivingButtonActionsFor:error:)])
            {
                [self.delegate didSubscribeToStartReceivingButtonActionsFor:self error:error];
            }
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(didUnsubscribeToStopRecivingButtonActionsFor:error:)])
            {
                [self.delegate didUnsubscribeToStopRecivingButtonActionsFor:self error:error];
            }
        }
    }
}

@end

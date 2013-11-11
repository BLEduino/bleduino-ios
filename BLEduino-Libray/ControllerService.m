//
//  ControllerService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "ControllerService.h"

#pragma mark -
#pragma mark Controller Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString *kControllerServiceUUIDString = @"8C6BF001-A312-681D-025B-0032C0D16A2D";
NSString *kButtonActionCharacteristicUUIDString = @"8C6BD00D-A312-681D-025B-0032C0D16A2D";

#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*								Setup										*/
/****************************************************************************/
@implementation ControllerService
{
    @private
    CBUUID              *_controllerServiceUUID;
    CBUUID              *_buttonActionCharacteristicUUID;
    
    id <ControllerServiceDelegate> _delegate;
    
    ButtonActionCharacteristic *_lastButtonAction;
}

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral controller:(id<ControllerServiceDelegate>)aController
{
    self = [super init];
    if (self) {
        _servicePeripheral = [aPeripheral copy];
        _servicePeripheral.delegate = self;
		_delegate = aController;
        
        _controllerServiceUUID = [CBUUID UUIDWithString:kControllerServiceUUIDString];
        _buttonActionCharacteristicUUID = [CBUUID UUIDWithString:kButtonActionCharacteristicUUIDString];
    }
    
    return self;
}

#pragma mark -
#pragma mark Writing to BLEduino
/****************************************************************************/
/*				      Write button action to BLEduino                       */
/****************************************************************************/
- (void) writeButtonAction:(ButtonActionCharacteristic *)buttonAction
                   withAck:(BOOL)enabled
{
    _lastButtonAction = buttonAction;
    [self writeDataToPeripheral:_servicePeripheral
                    serviceUUID:_controllerServiceUUID
             characteristicUUID:_buttonActionCharacteristicUUID
                           data:[buttonAction data]
                        withAck:enabled];
}

- (void) writeButtonAction:(ButtonActionCharacteristic *)buttonAction
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
    [self readDataFromPeripheral:_servicePeripheral
                     serviceUUID:_controllerServiceUUID
              characteristicUUID:_buttonActionCharacteristicUUID];
}

- (void) subscribeToStartReceivingButtonActions
{
    [self setNotificationForPeripheral:_servicePeripheral
                           serviceUUID:_controllerServiceUUID
                    characteristicUUID:_buttonActionCharacteristicUUID
                           notifyValue:YES];
}

- (void) unsubscribeToStopReiceivingButtonActions
{
    [self setNotificationForPeripheral:_servicePeripheral
                           serviceUUID:_controllerServiceUUID
                    characteristicUUID:_buttonActionCharacteristicUUID
                           notifyValue:NO];
}

#pragma mark -
#pragma mark Peripheral Delegate
/****************************************************************************/
/*				            Peripheral Delegate                             */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastButtonAction = _lastButtonAction;
    if([_delegate respondsToSelector:@selector(controllerService:didWriteButtonAction:error:)])
    {
        [_delegate controllerService:self
                didWriteButtonAction:self.lastButtonAction
                               error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.lastButtonAction = [[ButtonActionCharacteristic alloc] initWithData:characteristic.value];
    if([_delegate respondsToSelector:@selector(controllerService:didReceiveButtonAction:error:)])
    {
        [_delegate controllerService:self
              didReceiveButtonAction:self.lastButtonAction
                               error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.isNotifying)
    {
        if([_delegate respondsToSelector:@selector(didSubscribeToStartReceivingButtonActionsFor:error:)])
        {
            [_delegate didSubscribeToStartReceivingButtonActionsFor:self error:error];
        }
    }
    else
    {
        if([_delegate respondsToSelector:@selector(didUnsubscribeToStopRecivingButtonActionsFor:error:)])
        {
            [_delegate didUnsubscribeToStopRecivingButtonActionsFor:self error:error];
        }
    }
}


@end

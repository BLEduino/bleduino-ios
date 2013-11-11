//
//  ControllerService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleService.h"
#import "ButtonActionCharacteristic.h"

#pragma mark -
#pragma mark Controller Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString *kControllerServiceUUIDString;
//8C6BF001-A312-681D-025B-0032C0D16A2D  Controller Service

extern NSString *kButtonActionCharacteristicUUIDString;
//8C6BD00D-A312-681D-025B-0032C0D16A2D  Button Action Characteristic


#pragma mark -
#pragma mark Controller Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class ControllerService;
@protocol ControllerServiceDelegate <NSObject>
@optional
- (void)controllerService:(ControllerService *)service
   didReceiveButtonAction:(ButtonActionCharacteristic *)buttonAction
                    error:(NSError *)error;

- (void)controllerService:(ControllerService *)service
     didWriteButtonAction:(ButtonActionCharacteristic *)buttonAction
                    error:(NSError *)error;

- (void)didSubscribeToStartReceivingButtonActionsFor:(ControllerService *)service error:(NSError *)error;
- (void)didUnsubscribeToStopRecivingButtonActionsFor:(ControllerService *)service error:(NSError *)error;
@end

/****************************************************************************/
/*                          Controller Service                              */
/****************************************************************************/
@interface ControllerService : BleService <CBPeripheralDelegate>
@property (nonatomic, strong) ButtonActionCharacteristic *lastButtonAction;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral controller:(id<ControllerServiceDelegate>)aController;

#pragma mark -
#pragma mark Writing to BLEduino
// Write button actions to BLEduino.
- (void) writeButtonAction:(ButtonActionCharacteristic *)buttonAction withAck:(BOOL)enabled;
- (void) writeButtonAction:(ButtonActionCharacteristic *)buttonAction;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving button actions from BLEduino.
- (void) readButtonAction;
- (void) subscribeToStartReceivingButtonActions;
- (void) unsubscribeToStopReiceivingButtonActions;


@end

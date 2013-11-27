//
//  ControllerService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDBleService.h"
#import "BDButtonActionCharacteristic.h"

#pragma mark -
#pragma mark Controller Service UUIDs
/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString * const kControllerServiceUUIDString;
//8C6BF001-A312-681D-025B-0032C0D16A2D  Controller Service

extern NSString * const kButtonActionCharacteristicUUIDString;
//8C6BD00D-A312-681D-025B-0032C0D16A2D  Button Action Characteristic


#pragma mark -
#pragma mark Controller Service Protocol
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class BDControllerService;
@protocol ControllerServiceDelegate <NSObject>
@optional
- (void)controllerService:(BDControllerService *)service
   didReceiveButtonAction:(BDButtonActionCharacteristic *)buttonAction
                    error:(NSError *)error;

- (void)controllerService:(BDControllerService *)service
     didWriteButtonAction:(BDButtonActionCharacteristic *)buttonAction
                    error:(NSError *)error;

- (void)didSubscribeToStartReceivingButtonActionsFor:(BDControllerService *)service error:(NSError *)error;
- (void)didUnsubscribeToStopRecivingButtonActionsFor:(BDControllerService *)service error:(NSError *)error;
@end

/****************************************************************************/
/*                          Controller Service                              */
/****************************************************************************/
@interface BDControllerService : BDBleService <CBPeripheralDelegate>
@property (nonatomic, strong) BDButtonActionCharacteristic *lastButtonAction;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<ControllerServiceDelegate>)aController;

#pragma mark -
#pragma mark Writing to BLEduino
// Write button actions to BLEduino.
- (void) writeButtonAction:(BDButtonActionCharacteristic *)buttonAction withAck:(BOOL)enabled;
- (void) writeButtonAction:(BDButtonActionCharacteristic *)buttonAction;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving button actions from BLEduino.
- (void) readButtonAction;
- (void) subscribeToStartReceivingButtonActions;
- (void) unsubscribeToStopReiceivingButtonActions;


@end

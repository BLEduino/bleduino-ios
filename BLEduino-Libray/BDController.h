//
//  ControllerService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BDBleService.h"
#import "BDButtonAction.h"

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
@class BDController;
@protocol ControllerServiceDelegate <NSObject>
@optional
- (void)controllerService:(BDController *)service
   didReceiveButtonAction:(BDButtonAction *)buttonAction
                    error:(NSError *)error;

- (void)controllerService:(BDController *)service
     didWriteButtonAction:(BDButtonAction *)buttonAction
                    error:(NSError *)error;

- (void)didSubscribeToStartReceivingButtonActionsFor:(BDController *)service error:(NSError *)error;
- (void)didUnsubscribeToStopRecivingButtonActionsFor:(BDController *)service error:(NSError *)error;
@end

/****************************************************************************/
/*                          Controller Service                              */
/****************************************************************************/
@interface BDController : BDBleService <CBPeripheralDelegate>
@property (nonatomic, strong) BDButtonAction *lastButtonAction;

- (id) initWithPeripheral:(CBPeripheral *)aPeripheral
                 delegate:(id<ControllerServiceDelegate>)aController;

#pragma mark -
#pragma mark Writing to BLEduino
// Write button actions to BLEduino.
- (void) writeButtonAction:(BDButtonAction *)buttonAction withAck:(BOOL)enabled;
- (void) writeButtonAction:(BDButtonAction *)buttonAction;

#pragma mark -
#pragma mark Reading from BLEduino
// Read/Receiving button actions from BLEduino.
- (void) readButtonAction;
- (void) subscribeToStartReceivingButtonActions;
- (void) unsubscribeToStopReiceivingButtonActions;


@end

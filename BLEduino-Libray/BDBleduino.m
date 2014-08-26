//
//  BDWrite.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/7/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "BDBleduino.h"
#import "BDLeManager.h"

@interface BDBleduino ()
@property (strong) id<BleduinoDelegate> delegate;

//Services
@property (strong) BDFirmata *firmata;
@property (strong) BDController *controller;
@property (strong) BDVehicleMotion *motion;
@property (strong) BDUart *uart;
@property (strong) BDProximity *proximity;

@end

@implementation BDBleduino

#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*								Setup										*/
/****************************************************************************/
- (instancetype)initWithBleduino:(CBPeripheral *)bleduino
                        delegate:(id<BleduinoDelegate>)delegate
{
    self = [super init];
    if(self)
    {
        //Peripheral
        _bleduino = bleduino;
        self.delegate = delegate;
        
        //Services
        self.firmata    = [[BDFirmata alloc] initWithPeripheral:bleduino delegate:self];
        self.controller = [[BDController alloc] initWithPeripheral:bleduino delegate:self];
        self.motion     = [[BDVehicleMotion alloc] initWithPeripheral:bleduino delegate:self];
        self.uart       = [[BDUart alloc] initWithPeripheral:bleduino delegate:self];
        self.proximity  = [BDProximity sharedMonitor];
        
        BDLeManager *manager = [BDLeManager sharedLeManager];
        manager.isOnlyBleduinoDelegate = YES;
        self.bleduino.delegate = manager.bleduinoDelegate;
    }
    return self;
}


+ (instancetype)bleduino:(CBPeripheral *)bleduino
                delegate:(id<BleduinoDelegate>)delegate
{
    return [[BDBleduino alloc] initWithBleduino:bleduino delegate:delegate];
}

/*
 * The following methods allows developer to write/read/subscribe to:
 * Firmata, Controller, Vehicle Motion, and UART.
 */

#pragma mark -
#pragma mark - Write Dara
/****************************************************************************/
/*                         Write data to BLEduino                           */
/****************************************************************************/
+ (void) writeValue:(id)data
{
    BDLeManager *manager = [BDLeManager sharedLeManager];
    
    for(CBPeripheral *bleduino in manager.connectedBleduinos)
    {
        BDBleduino *writer = [BDBleduino bleduino:bleduino delegate:nil];
        [writer writeValue:data withAck:NO];
    }
}

+ (void) writeValue:(id)data bleduino:(CBPeripheral *)bleduino
{
    BDBleduino *writer = [BDBleduino bleduino:bleduino delegate:nil];
    [writer writeValue:data withAck:NO];
}

- (void) writeValue:(id)data withAck:(BOOL)enabled
{
    if([data isKindOfClass:[BDFirmataCommand class]])
    {
        BDFirmataCommand *command = data;
        [self.firmata writeFirmataCommand:command withAck:enabled];
    }
    else if([data isKindOfClass:[BDButtonAction class]])
    {
        BDButtonAction *action = data;
        [self.controller writeButtonAction:action withAck:enabled];
    }
    else if([data isKindOfClass:[BDThrottleYawRollPitch class]])
    {
        BDThrottleYawRollPitch *motion = data;
        [self.motion writeMotionUpdate:motion withAck:enabled];
    }
    else if([data isKindOfClass:[NSString class]])
    {
        NSString *message = data;
        [self.uart writeMessage:message withAck:enabled];
    }
    else if([data isKindOfClass:[NSData class]])
    {
        NSData *messageData = data;
        [self.uart writeData:messageData withAck:enabled];
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(bleduino:didFailToWrite:)])
        {
            [self.delegate bleduino:self.bleduino didFailToWrite:data];
        }
    }
}

- (void)writeValue:(id)data
{
    [self writeValue:data withAck:NO];
}

#pragma mark -
#pragma mark - Read Data
/****************************************************************************/
/*                          Read data from BLEduino                         */
/****************************************************************************/
- (void) readValue:(BlePipe)pipe
{
    switch (pipe) {
        case Firmata:
        {
            [self.firmata readFirmataCommand];
        }
            break;
            
        case Controller:
        {
            [self.controller readButtonAction];
        }
            break;
            
        case VehicleMotion:
        {
            [self.motion readMotionUpdate];
        }
            break;
            
        case UART:
        {
            [self.uart readData];
        }
            break;
    }
}

- (void) subscribe:(BlePipe)pipe
            notify:(BOOL)notify
{
    switch (pipe) {
        case Firmata:
        {
            if(notify)
            {
                [self.firmata subscribeToStartReceivingFirmataCommands];
            }
            else
            {
                [self.firmata unsubscribeToStopReiceivingFirmataCommands];
            }
        }
            break;
            
        case Controller:
        {
            if(notify)
            {
                [self.controller subscribeToStartReceivingButtonActions];
            }
            else
            {
                [self.controller unsubscribeToStopReiceivingButtonActions];
            }
        }
            break;
            
        case VehicleMotion:
        {
            if(notify)
            {
                [self.motion subscribeToStartReceivingMotionUpdates];
            }
            else
            {
                [self.motion unsubscribeToStopReiceivingMotionUpdates];
            }
        }
            break;
            
        case UART:
        {
            if(notify)
            {
                [self.uart subscribeToStartReceivingData];
            }
            else
            {
                [self.uart unsubscribeToStopReiceivingData];
            }
        }
            break;
    }
}


/*
 * This method allows the user to update the BLEduino's (GAP) name Over-The-Air (OTA).
 * It's done with a work-around (via BLE-Bridge), because iOS blocks the GAP characteristic 
 * for updating the device name.
 */
+ (void) updateBleduinoName:(CBPeripheral *)bleduino name:(NSString *)name
{
    //Setup data.
    NSMutableData *updateData = [[NSMutableData alloc] initWithCapacity:name.length+1];
    
    //Setup and attache name update command.
    Byte nameByte = (255 >> (0)) & 0xff;
    NSMutableData *nameCmdData = [NSMutableData dataWithBytes:&nameByte length:sizeof(nameByte)];
    [updateData appendData:nameCmdData];
    
    //Setup and attach name.
    NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
    [updateData appendData:nameData];

    //Setup transfer and send update.
    CBUUID *bridge = [CBUUID UUIDWithString:kBleBridgeServiceUUIDString];
    CBUUID *bridgeRx = [CBUUID UUIDWithString:kBridgeRxCharacteristicUUIDString];
    
    BDObject *gap = [BDObject initializeWithBleduino:bleduino];
    [gap writeDataToServiceUUID:bridge characteristicUUID:bridgeRx data:updateData withAck:NO];
}

#pragma mark -
#pragma mark - Services' Delegates
/****************************************************************************/
/*				            Services' Delegates                             */
/****************************************************************************/

//Firmata
- (void)firmataService:(BDFirmata *)service didWriteFirmataCommand:(BDFirmataCommand *)firmataCommand
                 error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
              didWriteValue:firmataCommand
                       pipe:Firmata
                      error:error];
}

- (void)firmataService:(BDFirmata *)service didReceiveFirmataCommand:(BDFirmataCommand *)firmataCommand
                 error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
             didUpdateValue:firmataCommand
                       pipe:Firmata
                      error:error];
}

- (void)didSubscribeToStartReceivingFirmataCommandsFor:(BDFirmata *)service error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
               didSubscribe:Firmata
                     notify:YES
                      error:error];
}

- (void)didUnsubscribeToStopReceivingFirmataCommandsFor:(BDFirmata *)service error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
               didSubscribe:Firmata
                     notify:NO
                      error:error];
}

//Controller
- (void)controllerService:(BDController *)service didWriteButtonAction:(BDButtonAction *)buttonAction
                    error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
              didWriteValue:buttonAction
                       pipe:Controller
                      error:error];
}

- (void)controllerService:(BDController *)service didReceiveButtonAction:(BDButtonAction *)buttonAction
                    error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
             didUpdateValue:buttonAction
                       pipe:Controller
                      error:error];
}

- (void)didSubscribeToStartReceivingButtonActionsFor:(BDController *)service error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
               didSubscribe:Controller
                     notify:YES
                      error:error];
}

- (void)didUnsubscribeToStopRecivingButtonActionsFor:(BDController *)service error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
               didSubscribe:Controller
                     notify:NO
                      error:error];
}

//VehicleMotion
- (void)vehicleMotionService:(BDVehicleMotion *)service didWriteMotion:(BDThrottleYawRollPitch *)motionUpdate error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
              didWriteValue:motionUpdate
                       pipe:VehicleMotion
                      error:error];
}

- (void)vehicleMotionService:(BDVehicleMotion *)service didReceiveMotion:(BDThrottleYawRollPitch *)motionUpdate error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
             didUpdateValue:motionUpdate
                       pipe:VehicleMotion
                      error:error];
}

- (void)didSubscribeToStartReceivingMotionUpdatesFor:(BDVehicleMotion *)service error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
               didSubscribe:VehicleMotion
                     notify:YES
                      error:error];
}

- (void)didUnsubscribeToStopRecivingMotionUpdatesFor:(BDVehicleMotion *)service error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
               didSubscribe:VehicleMotion
                     notify:NO
                      error:error];
}


//UART
- (void)uartService:(BDUart *)service didWriteData:(NSData *)data error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
              didWriteValue:data
                       pipe:UART
                      error:error];
}

- (void)uartService:(BDUart *)service didWriteMessage:(NSString *)message error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
              didWriteValue:message
                       pipe:UART
                      error:error];
}

- (void)uartService:(BDUart *)service didReceiveData:(NSData *)data error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
             didUpdateValue:data
                       pipe:UART
                      error:error];
}

- (void)uartService:(BDUart *)service didReceiveMessage:(NSString *)message error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
             didUpdateValue:message
                       pipe:UART
                      error:error];
}

- (void)didSubscribeToReceiveDataFor:(BDUart *)service error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
               didSubscribe:UART
                     notify:YES
                      error:error];
}

- (void)didSubscribeToReceiveMessagesFor:(BDUart *)service error:(NSError *)error
{
    [self.delegate bleduino:service.peripheral
               didSubscribe:UART
                     notify:NO
                      error:error];
}

@end

//
//  PowerSwitchButtonView.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "PowerSwitchButtonView.h"
#import "LeDiscoveryManager.h"
#import "FirmataService.h"

@implementation PowerSwitchButtonView
{
    CGPoint _offset;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//Send firmata command.
- (void)switchPowerOn
{
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    CBPeripheral *bleduino = [leManager.connectedBleduinos lastObject];
    
    //Build command.
    FirmataCommandCharacteristic *firmataCommand = [[FirmataCommandCharacteristic alloc] init];
    firmataCommand.pinState = FirmataCommandPinStateOutput;
    firmataCommand.pinNumber = 3;
    firmataCommand.pinValue = 255;
    
    FirmataService *firmataService = [[FirmataService alloc] initWithPeripheral:bleduino controller:nil];
    [firmataService writeFirmataCommand:firmataCommand];
}

- (void)switchPowerOff
{
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    CBPeripheral *bleduino = [leManager.connectedBleduinos lastObject];
    
    //Build command.
    FirmataCommandCharacteristic *firmataCommand = [[FirmataCommandCharacteristic alloc] init];
    firmataCommand.pinState = FirmataCommandPinStateOutput;
    firmataCommand.pinNumber = 3;
    firmataCommand.pinValue = 0;
    
    FirmataService *firmataService = [[FirmataService alloc] initWithPeripheral:bleduino controller:nil];
    [firmataService writeFirmataCommand:firmataCommand];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    
    _offset = [aTouch locationInView: self];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    [UIView beginAnimations:@"Dragging Power Switch" context:nil];
    
    
    self.frame = CGRectMake(self.frame.origin.x, location.y - _offset.y,
                            self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL isOnTopHalf = (self.center.y < 308)?YES:NO;
    
    CGRect newFrame;
    if(isOnTopHalf)
    {
        newFrame = CGRectMake(self.frame.origin.x, 0,
                              self.frame.size.width, self.frame.size.height);
        
        UILabel *switchMessage = (UILabel*)[self viewWithTag:100];
        switchMessage.text = @"ON";
        
        [self switchPowerOn];
    }
    else
    {
        newFrame = CGRectMake(self.frame.origin.x, 568 - (self.frame.size.height),
                              self.frame.size.width, self.frame.size.height);
        
        UILabel *switchMessage = (UILabel*)[self viewWithTag:100];
        switchMessage.text = @"OFF";
        
        [self switchPowerOff];
    }
    
    [UIView beginAnimations:@"Dragging Power Switch" context:nil];
    self.frame = newFrame;
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
}

@end

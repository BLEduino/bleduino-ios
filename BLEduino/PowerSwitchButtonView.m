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
    
    //Setttings
    NSInteger _pinNumber;
    UIColor *_statusColor;
}

- (void) initPowerSwitch
{
    //Set appareance.
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 0.8f;
    
    //Update module based on settings.
    int statusColorCode = [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_POWERRELAY_STATUS_COLOR];
    if(statusColorCode == PowerSwitchStatusColorBlue)
    {
        UIColor *lightBlue = [UIColor colorWithRed:38/255.0 green:109/255.0 blue:235/255.0 alpha:.90];
        _statusColor = lightBlue;
    }
    else
    {
        UIColor *lightGreen = [UIColor colorWithRed:0 green:200/255.0 blue:0 alpha:1.0];
        _statusColor = lightGreen;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initPowerSwitch];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        // Initialization code
        [self initPowerSwitch];
    }
    return self;
}

//Send firmata command.
- (void)switchPowerOn
{
    [self.delegate powerSwitchDidUpdateWithStateOn:YES];
}

- (void)switchPowerOff
{
    [self.delegate powerSwitchDidUpdateWithStateOn:NO];
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
    NSString *text;
    CGRect newFrame;

    //Update status message.
    UILabel *switchMessage = (UILabel*)[self viewWithTag:100];
    BOOL isOnTopHalf = (self.center.y < 252)?YES:NO;
    
    if(isOnTopHalf)
    {
        [self switchPowerOn];
        text = @"ON";
        newFrame = CGRectMake(self.frame.origin.x, 10,
                              self.frame.size.width, self.frame.size.height);
    }
    else
    {
        [self switchPowerOff];
        text = @"OFF";
        newFrame = CGRectMake(self.frame.origin.x, 568 - (self.frame.size.height) - 10 - 63,
                              self.frame.size.width, self.frame.size.height);
    }
    
    //Execute update.
    [UIView beginAnimations:@"Dragging Power Switch" context:nil];
    self.frame = newFrame;
    switchMessage.text = text;
    switchMessage.textColor = _statusColor;
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
}

@end

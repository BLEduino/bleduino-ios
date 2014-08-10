//
//  PowerSwitchButtonView.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "PowerSwitchButtonView.h"
#import "BDLeDiscoveryManager.h"
#import "BDFirmataService.h"

@interface PowerSwitchButtonView ()
@property CGPoint offset;

//Setttings
@property (strong) UIColor *statusColor;
@property PowerSwitchStatusColor colorCode;
@end

@implementation PowerSwitchButtonView

- (void) initPowerSwitch
{
    //Set appareance.
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 0.8f;
    
    //Update module based on settings.
    self.colorCode = [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_POWERRELAY_STATUS_COLOR];
    if(self.colorCode == PowerSwitchStatusColorBlue)
    {
        UIColor *lightBlue = [UIColor colorWithRed:38/255.0 green:109/255.0 blue:235/255.0 alpha:.90];
        self.statusColor = lightBlue;
    }
    else
    {
        UIColor *lightGreen = [UIColor colorWithRed:0 green:200/255.0 blue:0 alpha:1.0];
        self.statusColor = lightGreen;
    }
    
    UILabel *switchMessage = (UILabel*)[self viewWithTag:100];
    //Red because we are starting on OFF (red) state. 
    [switchMessage setTextColor:[UIColor redColor]];
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
        //[self setFrame:CGRectMake(10, 10, 300, 245)];
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    
    self.offset = [aTouch locationInView: self];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    
    CGRect newFrame = CGRectMake(self.frame.origin.x, location.y - self.offset.y,
                                 self.frame.size.width, self.frame.size.height);
    
    //Verify new location is within dragging space.
    if(newFrame.origin.y >= 10 && newFrame.origin.y <= 250)
    {
        [UIView beginAnimations:@"Dragging Power Switch" context:nil];
        self.frame =newFrame;
        [UIView commitAnimations];
    }
    
    NSLog(@"height: %f", self.frame.size.height);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL isOnTopHalf = (self.center.y < 252)?YES:NO;
    [self updatePowerSwitchView:isOnTopHalf];
}
   

- (void)updatePowerSwitchView:(BOOL)isOnTopHalf
{
    NSString *text;
    UIColor *color;
    CGRect newFrame;
    
    //Update status message.
    UILabel *switchMessage = (UILabel*)[self viewWithTag:100];
    
    if(isOnTopHalf)
    {
        [self switchPowerOn];
        text = @"ON";
        color = self.statusColor;
        newFrame = CGRectMake(self.frame.origin.x, 10,
                              self.frame.size.width, self.frame.size.height);
        
    }
    else
    {
        [self switchPowerOff];
        text = @"OFF";
        color = (self.colorCode == PowerSwitchStatusColorGreenRed)?[UIColor redColor]:self.statusColor;
        newFrame = CGRectMake(self.frame.origin.x, 568 - (self.frame.size.height) - 10 - 63,
                              self.frame.size.width, self.frame.size.height);
    }
    
    //Execute update.
    [UIView beginAnimations:@"Dragging Power Switch" context:nil];
    self.frame = newFrame;
    switchMessage.text = text;
    switchMessage.textColor = color;
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
}

- (void)updatePowerSwitchTextWithStateOn:(BOOL)isOn
{
    NSString *text;
    UIColor *color;
    
    //Update status message.
    UILabel *switchMessage = (UILabel*)[self viewWithTag:100];
    
    if(isOn)
    {
        text = @"ON";
        color = self.statusColor;
    }
    else
    {
        text = @"OFF";
        color = (self.colorCode == PowerSwitchStatusColorGreenRed)?[UIColor redColor]:self.statusColor;
    }
    
    //Execute update.
    [UIView beginAnimations:@"Dragging Power Switch" context:nil];
    switchMessage.text = text;
    switchMessage.textColor = color;
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
}

@end

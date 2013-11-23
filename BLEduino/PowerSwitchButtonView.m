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
        NSLog(@"X: %f Y: %f", frame.origin.x, frame.origin.y);
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
    BOOL isOnTopHalf = (self.center.y < 252)?YES:NO;
    
    CGRect newFrame;
    if(isOnTopHalf)
    {
        newFrame = CGRectMake(self.frame.origin.x, 10,
                              self.frame.size.width, self.frame.size.height);
        
        UILabel *switchMessage = (UILabel*)[self viewWithTag:100];
        switchMessage.text = @"ON";
        
        [self switchPowerOn];
    }
    else
    {
        newFrame = CGRectMake(self.frame.origin.x, 568 - (self.frame.size.height) - 10 - 63,
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

//
//  HorizontalJoystickControlView.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/19/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "HorizontalJoystickControlView.h"

@implementation HorizontalJoystickControlView
{
    UIImage *joystickNeutralImage;
    UIImage *joystickHoldImage;
    CGPoint _offset;
    
    //Joystick view.
@protected IBOutlet UIImageView *joystickView;
}

- (void) initJoystick
{
    joystickNeutralImage = [UIImage imageNamed:@"JoystickNeutral"];
    joystickHoldImage = [UIImage imageNamed:@"JoystickHold"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initJoystick];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
	{
        // Initialization code
        [self initJoystick];
    }
    return self;
}


#pragma mark -
#pragma mark Joystick Movement Methods
/****************************************************************************/
/*                      Joystick Control Movement							*/
/****************************************************************************/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Update joystick image to hold state image.
    joystickView.image = joystickHoldImage;
    
    UITouch *aTouch = [touches anyObject];
    _offset = [aTouch locationInView:joystickView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    UIView *view = [aTouch view];
    
    CGPoint location = [aTouch locationInView:view];
    CGPoint destination = CGPointMake(location.x - _offset.x, location.y - _offset.y);
    
    CGRect newFrame = CGRectMake(destination.x, destination.y, 90, 90);
    CGPoint center = CGPointMake(CGRectGetMidX(newFrame), CGRectGetMidY(newFrame));
    
    double differenceX = fabsf(center.x - 135);
    double differenceY = fabsf(center.y - 135);
    double maxDistance = sqrt((differenceX * differenceX) + (differenceY * differenceY));
    
    
    if(maxDistance > 89)
    {
        //Do nothing.
        //PENDING: Send max roll left or right. Need to check.
    }
    else
    {
        //Execute movement.
        [UIView beginAnimations:@"Dragging Power Switch" context:nil];
        joystickView.frame = CGRectMake(destination.x, joystickView.frame.origin.y, 90, 90);
        [UIView commitAnimations];
        
        //PENDING: Send roll information. Need to check.
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView beginAnimations:@"Moving Joystick" context:nil];
    joystickView.frame = CGRectMake(90, 90, 90, 90); //Center position.
    [UIView setAnimationDuration:0.1];
    [UIView commitAnimations];
    
    //Update joystick image to neutral state image.
    joystickView.image = joystickNeutralImage;
}

@end

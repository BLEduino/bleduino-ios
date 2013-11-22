//
//  VerticalJoystickControlView.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/19/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "VerticalJoystickControlView.h"

@implementation VerticalJoystickControlView
{
    UIImage *joystickNeutralImage;
    UIImage *joystickHoldImage;
    CGPoint _offset;
    
    //Joystick view.
    @protected IBOutlet UIImageView *joystickView;
}

- (void) initJoystick
{
    self.delegate = nil;
    joystickNeutralImage = [UIImage imageNamed:@"joystick-neutral.png"];
    joystickHoldImage = [UIImage imageNamed:@"joystick-hold.png"];
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
    
    double differenceY = fabsf(center.y - 135);
    double maxDistance = sqrt(differenceY * differenceY);
    
    if(maxDistance < 90)
    {
        //Send throttle data.
        [self.delegate verticalJoystickDidUpdate:center];
        
        //Execute movement.
        [UIView beginAnimations:@"Moving Joystick" context:nil];
        joystickView.frame = CGRectMake(joystickView.frame.origin.x, destination.y, 90, 90);
        [UIView commitAnimations];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect centerFrame = CGRectMake(90, 90, 90, 90); //Center position.
    CGPoint center = CGPointMake(CGRectGetMidX(centerFrame), CGRectGetMidY(centerFrame));
    
    //Send throttle data.
    [self.delegate verticalJoystickDidUpdate:center];
    
    [UIView beginAnimations:@"Moving Joystick" context:nil];
    joystickView.frame = centerFrame;
    [UIView setAnimationDuration:0.1];
    [UIView commitAnimations];
    
    //Update joystick image to neutral state image.
    joystickView.image = joystickNeutralImage;
}
@end

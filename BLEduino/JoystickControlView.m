//
//  JoystickControlView.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/19/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "JoystickControlView.h"

#pragma mark -
#pragma mark Setup
/****************************************************************************/
/*                                  Setup                                   */
/****************************************************************************/
@implementation JoystickControlView
{
    UIImage *joystickNeutralImage;
    UIImage *joystickHoldImage;
    CGPoint _offset;

    CGPoint previous;

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

- (void)touchEvent:(NSSet *)touches
{
    
    if([touches count] != 1)
        return ;
    
    
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    if(view != self)
        return ;
    
    
    UITouch *aTouch = [touches anyObject];
//    UIView *view = [aTouch view];
    CGPoint location = [aTouch locationInView:view];
    
    CGPoint destination = CGPointMake(location.x - _offset.x, location.y - _offset.y);
//    double maxDistance = sqrt((destination.x * destination.x) + (destination.y * destination.y));
//    NSLog(@"Max Distance: %f", maxDistance);
//    NSLog(@"Difference X:%f, Y:%f", fabsf(destination.x - 90), fabsf(destination.y - 90));


    CGRect newFrame = CGRectMake(destination.x, destination.y, 90, 90);
    CGPoint center = CGPointMake(CGRectGetMidX(newFrame), CGRectGetMidY(newFrame));
    
    double differenceX = fabsf(center.x - 135);
    double differenceY = fabsf(center.y - 135);
    
    NSLog(@"Difference X:%f, Y:%f", differenceX, differenceY);
    double maxDistance = sqrt((differenceX * differenceX) + (differenceY * differenceY));
    NSLog(@"Max Distance: %f", maxDistance);
    
    
    
    CGPoint dx;
    dx.x = location.x;// - 145;
    dx.y = location.y;//- 160;
    
    if(maxDistance > 89)
    {
    
        float angle = atan2f(dx.y, dx.x);// * (180/3.14159265); // in radians
//            float angle = dx.y/dx.x; // in radians
        
            NSLog(@"Destinations x: %f, y: %f", destination.x, destination.y);
            destination.x = 135 * cosf(angle);
            destination.y = 135 * sinf(angle);
            
            
            NSLog(@"Destinations 2 x: %f, y: %f", destination.x, destination.y);
            
            [UIView beginAnimations:@"Dragging Power Switch" context:nil];
            joystickView.frame = CGRectMake(destination.x, destination.y, 90, 90);
            [UIView commitAnimations];
    }
    else
    {
        //Execute movement.
        [UIView beginAnimations:@"Dragging Power Switch" context:nil];
        joystickView.frame = CGRectMake(destination.x, destination.y, 90, 90);
        [UIView commitAnimations];
        previous = destination;
    }
    
    
//    CGPoint touchPoint = [touch locationInView:view];
//    CGPoint dtarget, dir;
//    dir.x = touchPoint.x - 90;
//    dir.y = touchPoint.y - 90;
//    double len = sqrt(dir.x * dir.x + dir.y * dir.y);
//    
//
//    double len_inv = (1.0 / len);
//    dir.x *= len_inv;
//    dir.y *= len_inv;
//    dtarget.x = dir.x * .01f;
//    dtarget.y = dir.y * .01f;
//    
//    [UIView beginAnimations:@"Dragging Power Switch" context:nil];
//    joystickView.frame = CGRectMake(dtarget.x,  dtarget.y, 90, 90);
//    [UIView commitAnimations];
//    previous = destination;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Update joystick image to hold state image.
    joystickView.image = joystickHoldImage;
    
    UITouch *aTouch = [touches anyObject];
    _offset = [aTouch locationInView:joystickView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchEvent:touches];
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

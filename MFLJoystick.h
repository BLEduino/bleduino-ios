//
//  MFJoystick.h
//  
//
//  Created by teejay on 5/14/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol JoystickDelegate;
@interface MFLJoystick : UIView

@property CGFloat updateInterval;
@property (weak) id<JoystickDelegate> delegate;

- (void)setMovementUpdateInterval:(CGFloat)interval;
- (void)setThumbImage:(UIImage *)thumbImage andBGImage:(UIImage *)bgImage;
- (void)setMoveViscosity:(CGFloat)mv andSmallestValue:(CGFloat)sv;

@end

@protocol JoystickDelegate <NSObject>
@optional
- (void)joystick:(MFLJoystick *)aJoystick didUpdate:(CGPoint)movement;
@end
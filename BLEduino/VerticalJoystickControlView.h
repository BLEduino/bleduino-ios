//
//  VerticalJoystickControlView.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/19/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VerticalJoystickControlView;
@protocol VerticalJoystickControlViewDelegate <NSObject>
- (void)verticalJoystickDidUpdate:(CGPoint)position;
@end

@interface VerticalJoystickControlView : UIView
@property (weak) id <VerticalJoystickControlViewDelegate> delegate;
@property CGPoint lastPosition;
@end
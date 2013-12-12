//
//  HorizontalJoystickControlView.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/19/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HorizontalJoystickControlView;
@protocol HorizontalJoystickControlViewDelegate <NSObject>
- (void)horizontalJoystickDidUpdate:(CGPoint)position;
@end

@interface HorizontalJoystickControlView : UIView
@property (weak) id <HorizontalJoystickControlViewDelegate> delegate;
@property CGPoint lastPosition;
@end

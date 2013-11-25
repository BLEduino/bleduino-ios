//
//  PowerSwitchButtonView.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    PowerSwitchStatusColorBlue = 1,
    PowerSwitchStatusColorGreenRed = 2,
};
typedef NSUInteger PowerSwitchStatusColor;

@class PowerSwitchButtonView;
@protocol PowerSwitchButtonViewDelegate <NSObject>
- (void)powerSwitchDidUpdateWithStateOn:(BOOL)state;
@end

@interface PowerSwitchButtonView : UIView
@property (weak, nonatomic) id <PowerSwitchButtonViewDelegate> delegate;
- (void)updatePowerSwitchTextWithStateOn:(BOOL)isOn;
@end





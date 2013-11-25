//
//  PowerOtherStateView.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/25/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PowerOtherStateView;
@protocol PowerOtherStateViewDelegate <NSObject>
- (void)powerOtherStateDidUpdateWithStateOn:(BOOL)state;
@end

@interface PowerOtherStateView : UILabel
@property (weak, nonatomic) id <PowerOtherStateViewDelegate> delegate;

@end

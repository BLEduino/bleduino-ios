//
//  PowerOtherStateView.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/25/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PowerNextStateView;
@protocol PowerNextStateViewDelegate <NSObject>
- (void)powerOtherStateDidUpdateWithStateOn:(BOOL)state;
@end

@interface PowerNextStateView : UILabel
@property (weak) id <PowerNextStateViewDelegate> delegate;

@end

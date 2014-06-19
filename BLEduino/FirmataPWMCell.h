//
//  FirmataPWMCell.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 12/16/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirmataPWMCell : UITableViewCell
@property IBOutlet UILabel *pinNumber;
@property IBOutlet UILabel *pinState;
@property IBOutlet UIButton *pinValue;
@property UITableViewCellStateMask state;


//Redundant UILabel to display PWM value. iOS7 has a bug where the UIButton gets reloaded (with the content on the storyboard)
//when a UIActionView is shown.
@property IBOutlet UILabel *secondPinValue;
@end

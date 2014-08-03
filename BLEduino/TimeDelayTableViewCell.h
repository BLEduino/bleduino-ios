//
//  TimeDelayTableViewCell.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/16/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeDelayTableViewCell : UITableViewCell
@property IBOutlet UILabel *delayName;
@property IBOutlet UILabel *delayFormat;
@property IBOutlet UIButton *delayValue;
@property UITableViewCellStateMask state;


//Redundant UILabel to display PWM value. iOS7 has a bug where the UIButton gets reloaded (with the content on the storyboard)
//when a UIActionView is shown.
@property IBOutlet UILabel *secondDelayValue;
@end

//
//  SettingsSwitchCell.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/24/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsSwitchCell : UITableViewCell
@property (weak) IBOutlet UILabel *settingDescription;
@property (weak) IBOutlet UISwitch *settingsStatus;
@end

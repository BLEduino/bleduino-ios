//
//  ProximityRSSISettingsController.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/11/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProximityRSSISettingsController : UITableViewController
@property IBOutlet UISlider *immediateSlider;
@property IBOutlet UISlider *nearSlider;
@property IBOutlet UISlider *farSlider;
@property IBOutlet UILabel *immediateLabel;
@property IBOutlet UILabel *nearLabel;
@property IBOutlet UILabel *farLabel;
@end

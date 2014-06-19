//
//  FirmataDigitalCell.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 12/16/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirmataDigitalCell : UITableViewCell
@property IBOutlet UILabel *pinNumber;
@property IBOutlet UILabel *pinState;
@property IBOutlet UISwitch *pinValue;
@property UITableViewCellStateMask state;
@end

//
//  LEDTableViewCell.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/20/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "LEDTableViewCell.h"

@implementation LEDTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

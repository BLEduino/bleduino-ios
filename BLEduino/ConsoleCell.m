//
//  ConsoleCell.m
//  BLEduino
//
//  Created by Valerie Ann Rodriguez on 7/23/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "ConsoleCell.h"

@implementation ConsoleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

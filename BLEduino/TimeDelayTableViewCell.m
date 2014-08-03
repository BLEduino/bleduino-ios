//
//  TimeDelayTableViewCell.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/16/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "TimeDelayTableViewCell.h"

@implementation TimeDelayTableViewCell

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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    //If not swipe-to-remove, then hide accesory appropietly.
    if(self.state != UITableViewCellStateShowingDeleteConfirmationMask)
    {
        self.delayValue.hidden = editing;
        self.secondDelayValue.hidden = editing;
    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)aState
{
    [super willTransitionToState:aState];
    self.state = aState;
}

@end

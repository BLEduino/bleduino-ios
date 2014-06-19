//
//  FirmataAnalogCell.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 12/16/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "FirmataAnalogCell.h"

@implementation FirmataAnalogCell

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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    //If not swipe-to-remove, then hide accesory appropietly.
    if(self.state != UITableViewCellStateShowingDeleteConfirmationMask)
    {
        self.pinValue.hidden = editing;
    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)aState
{
    [super willTransitionToState:aState];
    self.state = aState;
}

@end

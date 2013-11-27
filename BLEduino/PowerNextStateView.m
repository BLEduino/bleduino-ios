//
//  PowerOtherStateView.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/25/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "PowerNextStateView.h"

@implementation PowerNextStateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL state = (self.tag == 300)?YES:NO;
    [self.delegate powerOtherStateDidUpdateWithStateOn:state];
}
@end

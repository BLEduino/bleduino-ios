//
//  BleduinoRoot.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/12/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleduinoRootController.h"
#import "SideMenuTableViewController.h"

@implementation BleduinoRootController
- (void)awakeFromNib
{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
    self.backgroundImage = [UIImage imageNamed:@"MenuBackground"];
    self.delegate = (SideMenuTableViewController *)self.menuViewController;
}
@end

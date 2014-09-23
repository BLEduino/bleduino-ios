//
//  BLEduinoTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/15/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "BleduinoController.h"
#import "BDBleduino.h"

@interface BleduinoController ()

@end

@implementation BleduinoController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.bleduinoName setDelegate:self];
    [self.bleduinoName becomeFirstResponder];
    [self.bleduinoName setPlaceholder:self.bleduino.name];
   
    CGRect header = CGRectMake(0, 0, 300, 100);
    UIView *headerView = [[UIView alloc] initWithFrame:header];
    self.tableView.tableHeaderView = headerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.bleduinoName.text.length <= 18)
    {
        NSString *trimmedName = [self.bleduinoName.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceCharacterSet]];
        
        if(trimmedName.length > 0)
        {
            [BDBleduino updateBleduinoName:self.bleduino name:trimmedName];
        }
        
        [self.delegate didUpateBleduino:self.bleduino controller:self];
    }
    else
    {
        NSString *message = @"The device name must be 18 characters or less.";
        UIAlertView *notificationAlert = [[UIAlertView alloc]initWithTitle:@"Name is too long"
                                                                   message:message
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles:nil];
        
        [notificationAlert show];
    }

    return NO;
}

- (IBAction)dismissModule:(id)sender
{
    [self.delegate didDismissBleduinoController:self];
}

- (IBAction)updateBleduinoName:(id)sender
{
    if(self.bleduinoName.text.length <= 18)
    {
        NSString *trimmedString = [self.bleduinoName.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceCharacterSet]];
        
        if(trimmedString.length > 0)
        {
            [BDBleduino updateBleduinoName:self.bleduino name:trimmedString];
        }
        
        [self.delegate didUpateBleduino:self.bleduino controller:self];
    }
    else
    {
        NSString *message = @"The device name must be 18 characters or less.";
        UIAlertView *notificationAlert = [[UIAlertView alloc]initWithTitle:@"Name is too long"
                                                                   message:message
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles:nil];
        
        [notificationAlert show];
    }
}

@end

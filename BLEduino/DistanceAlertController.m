//
//  EditDistanceAlertController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/18/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "DistanceAlertController.h"

@interface DistanceAlertController ()

@end

@implementation DistanceAlertController

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
    
    //Set appareance.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIColor *lightBlue = [UIColor colorWithRed:THEME_COLOR_RED/255.0
                                         green:THEME_COLOR_GREEN/255.0
                                          blue:THEME_COLOR_BLUE/255.0
                                         alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = lightBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.distanceControl.tintColor = lightBlue;
    
    //Set message delegate
    self.message.delegate = self;
    
    //If it is an update
    if(!self.isNewAlert)
    {
        //Populate with data of alert to be updated.
        self.message.text = self.alert.message;
        self.distanceControl.selectedSegmentIndex = self.alert.distance;
        [self.alertWhenCloser setOn:self.alert.bleduinoIsCloser animated:NO];
        [self.alertWhenFarther setOn:self.alert.bleduinoIsFarther animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissModule:(id)sender
{
    [self.delegate distanceAlertControllerDismissed:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.message resignFirstResponder];
    return NO;
}

- (IBAction)updateDistanceAlert:(id)sender
{
    if(self.message.text.length > 0)
    {
        if(self.isNewAlert)
        {
            self.alert = [[ProximityAlert alloc] init];
            self.alert.message = self.message.text;
            self.alert.distance = self.distanceControl.selectedSegmentIndex;
            self.alert.bleduinoIsCloser = self.alertWhenCloser.isOn;
            self.alert.bleduinoIsFarther = self.alertWhenFarther.isOn;
            self.alert.isDistanceAlert = YES;
            
            [self.delegate didCreateDistanceAlert:self.alert fromController:self];
        }
        else
        {
            self.alert.message = self.message.text;
            self.alert.message = self.message.text;
            self.alert.distance = self.distanceControl.selectedSegmentIndex;
            self.alert.bleduinoIsCloser = self.alertWhenCloser.isOn;
            self.alert.bleduinoIsFarther = self.alertWhenFarther.isOn;
            
            [self.delegate didUpdateDistanceAlert:self.alert fromController:self];
        }
    }
    else
    {
        NSString *message = @"The alert requires a message.";
        UIAlertView *notificationAlert = [[UIAlertView alloc]initWithTitle:@"Add Message"
                                                                   message:message
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles:nil];
        
        [notificationAlert show];
    }
}

@end

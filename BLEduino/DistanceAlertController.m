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
    }
    
    //If it is an update
    if(!self.isNewAlert)
    {
        //Populate with data of alert to be updated.
        self.message.text = self.alert.message;
        [self.alertWhenCloser setOn:self.alert.bleduinoIsCloser animated:NO];
        [self.alertWhenFarther setOn:self.alert.bleduinoIsFarther animated:NO];
        
        switch (self.alert.distance) {
            case 4:
                self.distanceControl.selectedSegmentIndex = 0;
                break;
            case 2:
                self.distanceControl.selectedSegmentIndex = 1;
                break;
            case 1:
                self.distanceControl.selectedSegmentIndex = 2;
                break;
            default:
                self.distanceControl.selectedSegmentIndex = 2;
                break;
        }
    }
    
    //First alert?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isFirstAlert = [defaults boolForKey:PROXIMITY_FIRST_ALERT];
    if(isFirstAlert)
    {
        NSString *message = @"Proximity alerts are only supported on the foreground. That is, you must have the application open for them to work.";
        UIAlertView *firstAlert = [[UIAlertView alloc]initWithTitle:@"Proximity Alerts"
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
        [firstAlert show];
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
            self.alert.bleduinoIsCloser = self.alertWhenCloser.isOn;
            self.alert.bleduinoIsFarther = self.alertWhenFarther.isOn;
            self.alert.isDistanceAlert = YES;
            
            switch (self.distanceControl.selectedSegmentIndex) {
                case 0:
                    self.alert.distance = 4;
                    break;
                case 1:
                    self.alert.distance = 2;
                    break;
                case 2:
                    self.alert.distance = 1;
                    break;
                default:
                    self.alert.distance = 0;
                    break;
            }
            
            [self.delegate didCreateDistanceAlert:self.alert fromController:self];
        }
        else
        {
            self.alert.message = self.message.text;
            self.alert.bleduinoIsCloser = self.alertWhenCloser.isOn;
            self.alert.bleduinoIsFarther = self.alertWhenFarther.isOn;
            
            switch (self.distanceControl.selectedSegmentIndex) {
                case 0:
                    self.alert.distance = 4;
                    break;
                case 1:
                    self.alert.distance = 2;
                    break;
                case 2:
                    self.alert.distance = 1;
                    break;
                default:
                    self.alert.distance = 0;
                    break;
            }
            
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

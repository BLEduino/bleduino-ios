//
//  RSSIDistanceAlertController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/9/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "RSSIAlertController.h"

@interface RSSIAlertController ()

@end

@implementation RSSIAlertController

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
    
    self.rssiSlider.tintColor = lightBlue;
    
    //Set message delegate
    self.message.delegate = self;
        
    //Setup slider update method.
    self.rssiSlider.value = -75;
    self.rssiSlider.continuous = YES;
    [self.rssiSlider addTarget:self
                        action:@selector(updateRSSIIndicator:)
              forControlEvents:UIControlEventValueChanged];
    
    //If it is an update
    if(!self.isNewAlert)
    {
        //Populate with data of alert to be updated.
        self.message.text = self.alert.message;
        self.rssiSlider.value = self.alert.distance;
    }
    
    NSInteger currentDistanceValue = self.rssiSlider.value;
    self.rssiIndicator.text = [NSString stringWithFormat:@"%ld dBm", (long)currentDistanceValue];
    
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
    [self.delegate rssiAlertControllerDismissed:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.message resignFirstResponder];
    return NO;
}

- (IBAction)updateRSSIAlert:(id)sender
{
    if(self.message.text.length > 0)
    {
        if(self.isNewAlert)
        {
            self.alert = [[ProximityAlert alloc] init];
            self.alert.message = self.message.text;
            self.alert.distance = self.rssiSlider.value;
            self.alert.isDistanceAlert = NO;
            
            [self.delegate didCreateRSSIAlert:self.alert fromController:self];
        }
        else
        {
            self.alert.message = self.message.text;
            self.alert.distance = self.rssiSlider.value;
            
            [self.delegate didUpdateRSSIAlert:self.alert fromController:self];
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

- (void)updateRSSIIndicator:(id)sender
{
    NSInteger currentRSSIValue = self.rssiSlider.value;
    self.rssiIndicator.text = [NSString stringWithFormat:@"%ld dBm", (long)currentRSSIValue];
}


@end

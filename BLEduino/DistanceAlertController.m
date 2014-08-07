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
    UIColor *lightBlue = [UIColor colorWithRed:38/255.0 green:109/255.0 blue:235/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = lightBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    //Set message delegate
    self.messageLabel.delegate = self;
    
    //Distance format?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL distanceFormatIsFeet = [defaults boolForKey:SETTINGS_PROXIMITY_DISTANCE_FORMAT_FT];
    [defaults synchronize];
    self.distanceFormat = (distanceFormatIsFeet)?@"ft":@"m";

    
    //Setup slider update method.
    self.distanceSlider.value = 75;
    self.distanceSlider.continuous = YES;
    [self.distanceSlider addTarget:self
                            action:@selector(updateDistanceIndicator:)
                  forControlEvents:UIControlEventValueChanged];
    
    //If it is an update
    if(!self.isNewAlert)
    {
        //Populate with data of alert to be updated.
        self.messageLabel.text = self.alert.message;
        self.distanceSlider.value = self.alert.distance;
        [self.alertWhenCloser setOn:self.alert.bleduinoIsCloser animated:NO];
        [self.alertWhenFarther setOn:self.alert.bleduinoIsFarther animated:NO];
    }
    
    NSInteger currentDistanceValue = self.distanceSlider.value;
    self.distanceIndicator.text = [NSString stringWithFormat:@"%ld %@", (long)currentDistanceValue, self.distanceFormat];
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
    [self.messageLabel resignFirstResponder];
    return NO;
}

- (IBAction)updateDistanceAlert:(id)sender
{
    if(self.isNewAlert)
    {
        self.alert = [[DistanceAlert alloc] init];
        self.alert.message = self.messageLabel.text;
        self.alert.distance = self.distanceSlider.value;
        self.alert.bleduinoIsCloser = self.alertWhenCloser.isOn;
        self.alert.bleduinoIsFarther = self.alertWhenFarther.isOn;
        
        [self.delegate didCreateDistanceAlert:self.alert fromController:self];
    }
    else
    {
        self.alert.message = self.messageLabel.text;
        self.alert.message = self.messageLabel.text;
        self.alert.distance = self.distanceSlider.value;
        self.alert.bleduinoIsCloser = self.alertWhenCloser.isOn;
        self.alert.bleduinoIsFarther = self.alertWhenFarther.isOn;
        
        [self.delegate didUpdateDistanceAlert:self.alert fromController:self];
    }
}

- (void)updateDistanceIndicator:(id)sender
{
    NSInteger currentDistanceValue = self.distanceSlider.value;
    self.distanceIndicator.text = [NSString stringWithFormat:@"%ld %@", (long)currentDistanceValue, self.distanceFormat];
}

@end

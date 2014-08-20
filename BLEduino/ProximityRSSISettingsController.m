//
//  ProximityRSSISettingsController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/11/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "ProximityRSSISettingsController.h"
#import "BDProximity.h"

@interface ProximityRSSISettingsController ()

@end

@implementation ProximityRSSISettingsController

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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float immediateRSSI = [defaults floatForKey:PROXIMITY_RSSI_IMMEDIATE_RANGE];
    float nearRSSI = [defaults floatForKey:PROXIMITY_RSSI_NEAR_RANGE];
    float farRSSI = [defaults floatForKey:PROXIMITY_RSSI_FAR_RANGE];
    [defaults synchronize];
    
    //Setup immediate slider update method.
    self.immediateSlider.value = immediateRSSI;
    self.immediateSlider.continuous = YES;
    [self.immediateSlider addTarget:self
                        action:@selector(updateImmediateRSSIIndicator:)
              forControlEvents:UIControlEventValueChanged];
    
    //Setup near slider update method.
    self.nearSlider.value = nearRSSI;
    self.nearSlider.continuous = YES;
    [self.nearSlider addTarget:self
                        action:@selector(updateNearRSSIIndicator:)
              forControlEvents:UIControlEventValueChanged];
    
    //Setup far slider update method.
    self.farSlider.value = farRSSI;
    self.farSlider.continuous = YES;
    [self.farSlider addTarget:self
                        action:@selector(updateFarRSSIIndicator:)
              forControlEvents:UIControlEventValueChanged];
    
    self.immediateLabel.text = [NSString stringWithFormat:@"%ld dBm", (long)immediateRSSI];
    self.nearLabel.text = [NSString stringWithFormat:@"%ld dBm", (long)nearRSSI];
    self.farLabel.text = [NSString stringWithFormat:@"%ld dBm", (long)farRSSI];
    
    UIColor *lightBlue = [UIColor colorWithRed:THEME_COLOR_RED/255.0
                                         green:THEME_COLOR_GREEN/255.0
                                          blue:THEME_COLOR_BLUE/255.0
                                         alpha:1.0];
    
    //Set Color
    self.immediateSlider.tintColor = lightBlue;
    self.nearSlider.tintColor = lightBlue;
    self.farSlider.tintColor = lightBlue;
    
    //Set Footer
    BDProximity *monitor = [BDProximity sharedMonitor];
    NSInteger measuredPower = [monitor.measuredPower integerValue];
    UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [footer setTextAlignment:NSTextAlignmentCenter];
    [footer setLineBreakMode:NSLineBreakByWordWrapping];
    [footer setTextColor:lightBlue];
    [footer setFont:[UIFont systemFontOfSize:15]];
    footer.text = [NSString stringWithFormat:@"Meassured Power: %lddBM", (long)measuredPower];
    self.tableView.tableFooterView = footer;
    
    //Setup header
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 10)];
    self.tableView.tableHeaderView = header;
}

- (void)updateImmediateRSSIIndicator:(id)slider
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithFloat:self.immediateSlider.value] forKey:PROXIMITY_RSSI_IMMEDIATE_RANGE];
    
    NSInteger currentRSSIValue = self.immediateSlider.value;
    self.immediateLabel.text = [NSString stringWithFormat:@"%ld dBm", (long)currentRSSIValue];
}

- (void)updateNearRSSIIndicator:(id)slider
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithFloat:self.nearSlider.value] forKey:PROXIMITY_RSSI_IMMEDIATE_RANGE];
    
    NSInteger currentRSSIValue = self.nearSlider.value;
    self.nearLabel.text = [NSString stringWithFormat:@"%ld dBm", (long)currentRSSIValue];
}

- (void)updateFarRSSIIndicator:(id)slider
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithFloat:self.farSlider.value] forKey:PROXIMITY_RSSI_IMMEDIATE_RANGE];
    
    NSInteger currentRSSIValue = self.farSlider.value;
    self.farLabel.text = [NSString stringWithFormat:@"%ld dBm", (long)currentRSSIValue];
}


- (void)viewWillDisappear:(BOOL)animated
{
    //Store everything.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.immediateSlider.value forKey:PROXIMITY_RSSI_IMMEDIATE_RANGE];
    [defaults setFloat:self.nearSlider.value forKey:PROXIMITY_RSSI_NEAR_RANGE];
    [defaults setFloat:self.farSlider.value forKey:PROXIMITY_RSSI_FAR_RANGE];
    [defaults synchronize];
    
    //Update the proximity monitor. 
    BDProximity *monitor = [BDProximity sharedMonitor];
    monitor.immediateRSSI = self.immediateSlider.value;
    monitor.nearRSSI = self.nearSlider.value;
    monitor.farRSSI = self.farSlider.value;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

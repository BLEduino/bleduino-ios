//
//  GameControllerViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "GameControllerViewController.h"
#import "LeDiscoveryManager.h"
#import "ButtonActionCharacteristic.h"
#import "ControllerService.h"

@interface GameControllerViewController ()

@end

@implementation GameControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    MFLJoystick *joystick = [[MFLJoystick alloc] initWithFrame:CGRectMake(10, 25, 270, 270)];
    [joystick setThumbImage:[UIImage imageNamed:@"JoystickNeutral"]
                 andBGImage:[UIImage imageNamed:@"joystick-bg.png"]];
    [joystick setDelegate:self];
    [self.view addSubview:joystick];
}

- (void)joystick:(MFLJoystick *)aJoystick didUpdate:(CGPoint)dir
{
//    NSLog(@"%@", NSStringFromCGPoint(dir));
//    CGPoint newpos = self.playerOrigin;
//    newpos.x = 30.0 * dir.x + self.playerOrigin.x;
//    newpos.y = 30.0 * dir.y + self.playerOrigin.y;
//    CGRect fr = self.player.frame;
//    fr.origin = newpos;
//    self.player.frame = fr;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)upButton:(id)sender {
    
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    CBPeripheral *bleduino = [leManager.connectedBleduinos lastObject];
    
    //Build button action.
    ButtonActionCharacteristic *action = [[ButtonActionCharacteristic alloc] init];
    action.buttonValue = 20;
    action.buttonID = 22;
    action.buttonStatus = 1;
    
    ControllerService *controller = [[ControllerService alloc] initWithPeripheral:bleduino controller:self];
    [controller writeButtonAction:action];
    
    NSLog(@"Controller update sent.");
}
- (IBAction)down:(id)sender {
    
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    CBPeripheral *bleduino = [leManager.connectedBleduinos lastObject];
    
    //Build button action.
    ButtonActionCharacteristic *action = [[ButtonActionCharacteristic alloc] init];
    action.buttonValue = 120;
    action.buttonID = 22;
    action.buttonStatus = 1;
    
    ControllerService *controller = [[ControllerService alloc] initWithPeripheral:bleduino controller:self];
    [controller writeButtonAction:action];
    
    NSLog(@"Controller update sent.");
}

- (IBAction)leftButton:(id)sender {
}

- (IBAction)rightButton:(id)sender {
}


- (IBAction)aButton:(id)sender {
}

- (IBAction)bButton:(id)sender {
}

- (IBAction)xButton:(id)sender {
}

- (IBAction)yButton:(id)sender {
}
@end

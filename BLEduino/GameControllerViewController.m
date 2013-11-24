//
//  GameControllerViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/14/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "GameControllerViewController.h"
#import "LeDiscoveryManager.h"
#import "ControllerService.h"
#import "ButtonActionCharacteristic.h"
#import "OBShapedButton.h"

#pragma mark -
#pragma mark Setup
/****************************************************************************/
/*                                  Setup                                   */
/****************************************************************************/
@implementation GameControllerViewController
{
    IBOutlet OBShapedButton *yButton;
    IBOutlet OBShapedButton *xButton;
    IBOutlet OBShapedButton *aButton;
    IBOutlet OBShapedButton *bButton;
    
    IBOutlet UIButton *start;
    IBOutlet UIButton *select;
}

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
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //Setup joystick.
    MFLJoystick *joystick = [[MFLJoystick alloc] initWithFrame:CGRectMake(10, 25, 270, 270)];
    [joystick setThumbImage:[UIImage imageNamed:@"joystick-neutral.png"]
                 andBGImage:[UIImage imageNamed:@"joystick-bg.png"]];
    [joystick setDelegate:self];
    [self.view addSubview:joystick];
    
    //Setup dismiss button.
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.frame = CGRectMake(34, 20, 14, 28);
    [dismissButton setImage:[UIImage imageNamed:@"arrow-left.png"] forState:UIControlStateNormal];
    [dismissButton addTarget:self
                      action:@selector(dismissModule)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:dismissButton];
    
    //Setup push buttons.
    //Button Pressing Down Observer
    [xButton addTarget:self action:@selector(xButton:) forControlEvents:UIControlEventTouchDown];
    [yButton addTarget:self action:@selector(yButton:) forControlEvents:UIControlEventTouchDown];
    [aButton addTarget:self action:@selector(aButton:) forControlEvents:UIControlEventTouchDown];
    [bButton addTarget:self action:@selector(bButton:) forControlEvents:UIControlEventTouchDown];
    
    //Button Released Observer
    [xButton addTarget:self action:@selector(xButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
    [yButton addTarget:self action:@selector(yButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
    [aButton addTarget:self action:@selector(aButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
    [bButton addTarget:self action:@selector(bButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
    
    //Start/Select buttons.
    [start addTarget:self action:@selector(startButton:) forControlEvents:UIControlEventTouchDown];
    [select addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchDown];
    
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

- (void)dismissModule
{
    [self.delegate gameControllerModuleViewControllerDismissed:self];
}

/****************************************************************************/
/*                       Button Action Updates                              */
/****************************************************************************/

#pragma mark -
#pragma mark - Joystick Updates
//Vertical Resolution: 200, 135 > neutral, 35 > 90 (Max up), 235 > -90 (Max down)
//Horizontal Resolution: 200, 135 > neutral, 35 > 90 (Max left), 235 > -90 (Max right)
- (void)joystick:(MFLJoystick *)aJoystick didUpdate:(CGPoint)dir
{
    //Create Vertical Joystick action.
    ButtonActionCharacteristic *vJoystickUpdate = [[ButtonActionCharacteristic alloc] init];
    vJoystickUpdate.buttonValue = dir.y;
    vJoystickUpdate.buttonID = 0;
    
    //Create Horizontal Joystick action.
    ButtonActionCharacteristic *hJoystickUpdate = [[ButtonActionCharacteristic alloc] init];
    hJoystickUpdate.buttonValue = dir.x;
    hJoystickUpdate.buttonID = 1;

    //Send joystick action.
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        ControllerService *gameController = [[ControllerService alloc] initWithPeripheral:bleduino
                                                                               controller:self];
        [gameController writeButtonAction:vJoystickUpdate]; //Vertical
        [gameController writeButtonAction:hJoystickUpdate]; //Horizontal
    }
    
    NSLog(@"GameController, sent *Vertical Joystick* action update, state: %f", dir.y);
    NSLog(@"GameController, sent *Horizontal Joystick* action update, state: %f", dir.x);
}

#pragma mark -
#pragma mark Button Pushed Down
//Send button pushed down action.
- (void)yButton:(id)sender
{
    [self ySendUpdateWithStateSelected:YES];
}

- (void)xButton:(id)sender
{
    [self xSendUpdateWithStateSelected:YES];
}

- (void)aButton:(id)sender
{
    [self aSendUpdateWithStateSelected:YES];
}

- (void)bButton:(id)sender
{
    [self bSendUpdateWithStateSelected:YES];
}

#pragma mark -
#pragma mark Button Released
//Send button released action.
- (void)yButtonReleased:(id)sender
{
    [self ySendUpdateWithStateSelected:NO];
}

- (void)xButtonReleased:(id)sender
{
    [self xSendUpdateWithStateSelected:NO];
}

- (void)aButtonReleased:(id)sender
{
    [self aSendUpdateWithStateSelected:NO];
}

- (void)bButtonReleased:(id)sender
{
    [self bSendUpdateWithStateSelected:NO];
}

#pragma mark -
#pragma mark Send Button Action Updates
//Send button action updates.
- (void)ySendUpdateWithStateSelected:(BOOL)selected
{
    //Create button action.
    ButtonActionCharacteristic *yButtonUpdate = [[ButtonActionCharacteristic alloc] init];
    yButtonUpdate.buttonStatus = [[NSNumber numberWithBool:selected] integerValue];
    yButtonUpdate.buttonID = 2;
    
    //Send button action.
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        ControllerService *gameController = [[ControllerService alloc] initWithPeripheral:bleduino
                                                                               controller:self];
        [gameController writeButtonAction:yButtonUpdate];
    }
    
    NSLog(@"GameController, sent button *Y* action update, state: %i", selected);
}

- (void)xSendUpdateWithStateSelected:(BOOL)selected
{
    //Create button action.
    ButtonActionCharacteristic *xButtonUpdate = [[ButtonActionCharacteristic alloc] init];
    xButtonUpdate.buttonStatus = [[NSNumber numberWithBool:selected] integerValue];
    xButtonUpdate.buttonID = 3;
    
    //Send button action.
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        ControllerService *gameController = [[ControllerService alloc] initWithPeripheral:bleduino
                                                                               controller:self];
        [gameController writeButtonAction:xButtonUpdate];
    }
    
    NSLog(@"GameController, sent button *X* action update, state: %i", selected);
}

- (void)aSendUpdateWithStateSelected:(BOOL)selected
{
    //Create button action.
    ButtonActionCharacteristic *aButtonUpdate = [[ButtonActionCharacteristic alloc] init];
    aButtonUpdate.buttonStatus = [[NSNumber numberWithBool:selected] integerValue];
    aButtonUpdate.buttonID = 4;
    
    //Send button action.
    ControllerService *gameController = [[ControllerService alloc] initWithPeripheral:nil
                                                                           controller:self];
    [gameController writeButtonAction:aButtonUpdate];
    
    NSLog(@"GameController, sent button *A* action update, state: %i", selected);
}

- (void)bSendUpdateWithStateSelected:(BOOL)selected
{
    //Create button action.
    ButtonActionCharacteristic *bButtonUpdate = [[ButtonActionCharacteristic alloc] init];
    bButtonUpdate.buttonStatus = [[NSNumber numberWithBool:selected] integerValue];
    bButtonUpdate.buttonID = 5;
    
    //Send button action.
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        ControllerService *gameController = [[ControllerService alloc] initWithPeripheral:bleduino
                                                                               controller:self];
        [gameController writeButtonAction:bButtonUpdate];
    }
    
    NSLog(@"GameController, sent button *B* action update, state: %i", selected);
}

#pragma mark -
#pragma mark Start/Select buttons
//Send start/select action.
- (void)startButton:(id)sender
{
    //Create button action.
    ButtonActionCharacteristic *startButtonUpdate = [[ButtonActionCharacteristic alloc] init];
    startButtonUpdate.buttonStatus = 1;
    startButtonUpdate.buttonID = 6;
    
    //Send button action.
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        ControllerService *gameController = [[ControllerService alloc] initWithPeripheral:bleduino
                                                                               controller:self];
        [gameController writeButtonAction:startButtonUpdate];
    }
    
    NSLog(@"GameController, sent button *Start* action update");
}

- (void)selectButton:(id)sender
{
    //Create button action.
    ButtonActionCharacteristic *selectButtonUpdate = [[ButtonActionCharacteristic alloc] init];
    selectButtonUpdate.buttonStatus = 1;
    selectButtonUpdate.buttonID = 6;
    
    //Send button action.
    LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
    
    for(CBPeripheral *bleduino in leManager.connectedBleduinos)
    {
        ControllerService *gameController = [[ControllerService alloc] initWithPeripheral:bleduino
                                                                               controller:self];
        [gameController writeButtonAction:selectButtonUpdate];
    }
    
    NSLog(@"GameController, sent button *Select* action update");
}

@end

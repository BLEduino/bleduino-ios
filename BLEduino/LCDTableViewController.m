//
//  LCDTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/22/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "LCDTableViewController.h"
#import "LeDiscoveryManager.h"

#pragma mark -
#pragma mark Setup
/****************************************************************************/
/*                                  Setup                                   */
/****************************************************************************/
@implementation LCDTableViewController
{
    NSInteger _totalAvailableChars;
}

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
    
    self.messageView.delegate = self;
    [self.messageView becomeFirstResponder];
    
    //Set appareance.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIColor *lightBlue = [UIColor colorWithRed:38/255.0 green:109/255.0 blue:235/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = lightBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    //Load total available characters.
    _totalAvailableChars = [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_LCD_TOTAL_CHARS];
    self.charCountView.text = [NSString stringWithFormat:@"%d", _totalAvailableChars];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissModule
{
    [self.delegate lcdModuleTableViewControllerDismissed:self];
}

#pragma mark -
#pragma mark TextView Delegate
/****************************************************************************/
/*                          TextView Delegate                               */
/****************************************************************************/
- (void)textViewDidChange:(UITextView *)textView
{
    //How many chars left?
    NSInteger charsLeft = _totalAvailableChars - textView.text.length;
    
    //Over the limit?
    if(charsLeft < 0)
    {
        self.charCountView.textColor = [UIColor redColor];
    }
    else
    {
        //Change text color back to Tungsten.
        self.charCountView.textColor = [UIColor colorWithRed:51/255
                                                   green:51/255
                                                    blue:51/255
                                                   alpha:1.0];
    }
    self.charCountView.text = [NSString stringWithFormat:@"%d", charsLeft];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
        
        for(CBPeripheral *bleduino in leManager.connectedBleduinos)
        {
            NSString *message = self.messageView.text;
            UARTService *messageService = [[UARTService alloc] initWithPeripheral:bleduino controller:self];
            [messageService writeMessage:message];
        }
    
        //Clear text view.
        self.messageView.text = @"";
    }
    
    return YES;
}

@end

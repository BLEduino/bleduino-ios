//
//  LCDTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/22/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "LCDTableViewController.h"
#import "BDLeDiscoveryManager.h"

#pragma mark -
#pragma mark Setup
/****************************************************************************/
/*                                  Setup                                   */
/****************************************************************************/
@interface LCDTableViewController ()
@property NSInteger totalAvailableChars;
@end

@implementation LCDTableViewController

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
    self.totalAvailableChars = [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_LCD_TOTAL_CHARS];
    self.charCountView.text = [NSString stringWithFormat:@"%ld", (long)self.totalAvailableChars];
    
    //Manager Delegate
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    leManager.delegate = self;

    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
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
    NSInteger charsLeft = self.totalAvailableChars - textView.text.length;
    
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
    self.charCountView.text = [NSString stringWithFormat:@"%ld", (long)charsLeft];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        if(self.messageView.text.length <= self.totalAvailableChars)
        {
            BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
            
            for(CBPeripheral *bleduino in leManager.connectedBleduinos)
            {
                NSString *message = self.messageView.text;
                BDUartService *messageService = [[BDUartService alloc] initWithPeripheral:bleduino delegate:self];
                [messageService writeMessage:message];
            }
            
            [textView setContentOffset:CGPointMake(0, 0) animated:YES];
            self.messageView.text = @"";
        }
        else
        {
            NSString *message = [NSString stringWithFormat:
                                 @"The text you are trying to send to the BLEduino is too long. You entered %lu characters and you have set your total available characters to %li. If you want to send more characters please go to the Settings section and update the LCD total available characters.",
                                 (unsigned long)self.messageView.text.length,
                                 (long)self.totalAvailableChars];
            UIAlertView *textTooLongAlert = [[UIAlertView alloc]initWithTitle:@"Text is too long"
                                                                       message:message
                                                                      delegate:nil
                                                             cancelButtonTitle:@"Ok"
                                                             otherButtonTitles:nil];
            
            [textTooLongAlert show];
        }
    }
    
     return ([text isEqualToString:@"\n"])?NO:YES;
}

#pragma mark -
#pragma mark - LeManager Delegate
/****************************************************************************/
/*                            LeManager Delegate                            */
/****************************************************************************/
//Disconnected from BLEduino and BLE devices.
- (void) didDisconnectFromBleduino:(CBPeripheral *)bleduino error:(NSError *)error
{
    NSString *name = ([bleduino.name isEqualToString:@""])?@"BLE Peripheral":bleduino.name;
    NSLog(@"Disconnected from peripheral: %@", name);
    
    //Verify if notify setting is enabled.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL notifyDisconnect = [prefs integerForKey:SETTINGS_NOTIFY_DISCONNECT];
    
    if(notifyDisconnect)
    {
        NSString *message = [NSString stringWithFormat:@"The BLE device '%@' has disconnected from the BLEduino app.", name];

        //Push local notification.
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody = message;
        notification.alertAction = nil;
        
        //Is application on the foreground?
        if([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)
        {
            //Application is on the foreground, store notification attributes to present alert view.
            notification.userInfo = @{@"title"  : @"BLEduino",
                                      @"message": message,
                                      @"disconnect": @"disconnect"};
        }
        
        //Present notification.
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

@end

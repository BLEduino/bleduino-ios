//
//  KeyboardModuleTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "KeyboardModuleTableViewController.h"
#import "BDLeManager.h"
#import "BDUart.h"
#import "BDBleduino.h"

#pragma mark -
#pragma mark Setup
/****************************************************************************/
/*                                  Setup                                   */
/****************************************************************************/
@implementation KeyboardModuleTableViewController

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
    UIColor *lightBlue = [UIColor colorWithRed:THEME_COLOR_RED/255.0
                                         green:THEME_COLOR_GREEN/255.0
                                          blue:THEME_COLOR_BLUE/255.0
                                         alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = lightBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    //Manager Delegate
    BDLeManager *leManager = [BDLeManager sharedLeManager];
    leManager.delegate = self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark TextView Delegate
/****************************************************************************/
/*                          TextView Delegate                               */
/****************************************************************************/
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        BDLeManager *leManager = [BDLeManager sharedLeManager];
        for(CBPeripheral *bleduino in leManager.connectedBleduinos)
        {
            [self writeMessage:self.messageView.text bleduino:bleduino];
        }

        //Clear text view.
        [textView setContentOffset:CGPointMake(0, 0) animated:YES];
        self.messageView.text = @"";
    }
    
    return ([text isEqualToString:@"\n"])?NO:YES;
}

/*
 * This method implements the logic to send messages to the BLEduino's LCD module (via the UART pipe/service),
 * regardless of its length.
 *
 * Bluetooth LE caps trasnfers at 20 bytes. That is, the BLEduino can only receive 20 bytes at a time.
 * Therefore, any transfers bigger than that must be splitted in chunks of 20 bytes. This limitation is not handled
 * automatically by design. The UART pipe/service is meant to be the most versatile and flexible one, and for that
 * reason, we have left the decision on how to best use UART, completely upt to the user. The following, is our
 * decision on how to best use it for the Keyboard module.
 *
 */
- (void) writeMessage:(NSString *)message bleduino:(CBPeripheral *)bleduino
{
    BDUart *messageService = [[BDUart alloc] initWithPeripheral:bleduino delegate:self];
   
    if(message.length > 20)
    {
        BOOL lastPacket = false;
        NSInteger subsstringPointer = 0;
        NSInteger totalPackets = ceil(message.length / 20.0);
        
        NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
        
        for (int packetIndex = 0; packetIndex < totalPackets; packetIndex++)
        {
            //Check if last (chunk of) transmission.
            lastPacket = (packetIndex == (totalPackets-1));
            
            //Setup range for subset/chunck of data being transfer.
            NSInteger rangeLength = (lastPacket)?(message.length - subsstringPointer):20;
            NSRange dataRange = NSMakeRange(subsstringPointer, rangeLength);
            
            //Get substring being tranfer.
            NSData *dataSubset = [messageData subdataWithRange:dataRange];
            
            //Write (part of) message.
            [messageService writeData:dataSubset];
            
            NSLog(@"\nWrote date from: %ld to: %ld, of %ld characters. \nSubstring: |%@| \nData length: %ld\nData: %@\n\n",
                  (long)subsstringPointer,
                  (long)(subsstringPointer+rangeLength),
                  (long)message.length,
                  [message substringWithRange:dataRange],
                  (unsigned long)dataSubset.length,
                  [dataSubset description]);
            
            //Move pointer to the beginning of next packet.
            subsstringPointer = subsstringPointer + 20;
        }
    }
    else
    {
        [messageService writeMessage:message];
    }
}

- (IBAction)dismissModule
{
    [self.delegate keyboardModuleTableViewControllerDismissed:self];
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

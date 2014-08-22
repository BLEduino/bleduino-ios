//
//  LCDTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/22/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "LCDTableViewController.h"
#import "BDLeManager.h"

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
    UIColor *lightBlue = [UIColor colorWithRed:THEME_COLOR_RED/255.0
                                         green:THEME_COLOR_GREEN/255.0
                                          blue:THEME_COLOR_BLUE/255.0
                                         alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = lightBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    //Load total available characters.
    self.totalAvailableChars = [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_LCD_TOTAL_CHARS];
    self.charCountView.text = [NSString stringWithFormat:@"%ld", (long)self.totalAvailableChars];
    
    //Manager Delegate
    BDLeManager *leManager = [BDLeManager sharedLeManager];
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
            BDLeManager *leManager = [BDLeManager sharedLeManager];
            
            for(CBPeripheral *bleduino in leManager.connectedBleduinos)
            {
                [self writeMessage:self.messageView.text bleduino:bleduino];
            }
            
            [textView setContentOffset:CGPointMake(0, 0) animated:YES];
            self.messageView.text = @"";
            self.charCountView.text = [NSString stringWithFormat:@"%ld", (long)self.totalAvailableChars];
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

/*
 * This method implements the logic to send messages to the BLEduino's LCD module (via the UART pipe/service), 
 * regardless of its length.
 *
 * Bluetooth LE caps trasnfers at 20 bytes. That is, the BLEduino can only receive 20 bytes at a time.
 * Therefore, any transfers bigger than that must be splitted in chunks of 20 bytes. This limitation is not handled
 * automatically by design. The UART pipe/service is meant to be the most versatile and flexible one, and for that 
 * reason, we have left the decision on how to best use UART, completely upt to the user. The following, is our 
 * decision on how to best use it for the LCD module.
 *
 * Now, in addition to having a data tranfer cap, the LCD module is meant to be completely agnostic to the actual 
 * LCD (sreen size) receiveing the message. Hence, the module limits the transfer by a total amount of characters
 * avaiable, and not a specific size (e.g. 16x2). Therefore, because the LCD module, purposely, does not know the 
 * number of columns and rows the LCD has, it must indicate the size of message somewhoe, so the BLEduino can 
 * determine how to best accomdoate the message knowing the limitations of the LCD's screen (columns/rows).
 *
 * We accomplish this by embedding a progress status on the first byte of each write. There are three (3)
 * different statuses: 
 * 0 > starting message transfer
 * 1 > ongoing message transfer
 * 2 > finished message transfer
 *
 */
- (void) writeMessage:(NSString *)message bleduino:(CBPeripheral *)bleduino
{
    
    BDUart *messageService = [[BDUart alloc] initWithPeripheral:bleduino delegate:self];

        BOOL lastPacket = false;
        NSInteger subsstringPointer = 0;
        NSInteger totalPackets = ceil(message.length / 19.0);
    
        NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    for (int packetIndex = 0; packetIndex < totalPackets; packetIndex++)
    {
        //Check if last (chunk of) transmission.
        lastPacket = (packetIndex == (totalPackets-1));
        
        //Setup range for subset/chunck of data being transfer.
        NSInteger rangeLength = (lastPacket)?(message.length - subsstringPointer):19;
        NSRange dataRange = NSMakeRange(subsstringPointer, rangeLength);
        
        //Get substring being tranfer.
        NSData *dataSubset = [messageData subdataWithRange:dataRange];
        
        //Holds the data being trasnfer.
        NSMutableData *data = [[NSMutableData alloc] initWithCapacity:[dataSubset length]+1];
        
        //Include state data.
        if (packetIndex == 0)
        {//Starting transmission.
            
            Byte startByte = (0 >> (0)) & 0xff;
            NSMutableData *startData = [NSMutableData dataWithBytes:&startByte length:sizeof(startByte)];
            [data appendData:startData];
            NSLog(@"Starting transmission...\n");
        }
        else if(lastPacket)
        {//Ending transmission.
            
            Byte endByte = (2 >> (0)) & 0xff;
            NSMutableData *endData = [NSMutableData dataWithBytes:&endByte length:sizeof(endByte)];
            [data appendData:endData];
            NSLog(@"Finished transmission...\n");
        }
        else
        {//Transmission is in transit.
            
            Byte transitByte = (1 >> (0)) & 0xff;
            NSMutableData *transitData = [NSMutableData dataWithBytes:&transitByte length:sizeof(transitByte)];
            [data appendData:transitData];
            NSLog(@"Ongoing transmission...\n");
        }
        
        NSLog(@"Data size before message: %ld", (long)data.length);
        //Append sub-message data.
        [data appendData:dataSubset];
        
        //Write (part of) message.
        [messageService writeData:data];
        
        NSLog(@"\nWrote date from: %ld to: %ld, of %ld characters. \nSubstring: |%@| \nData length: %ld \n\n",
              (long)subsstringPointer,
              (long)(subsstringPointer+rangeLength),
              (long)message.length,
              [message substringWithRange:dataRange],
              (unsigned long)data.length);
        
        //Move pointer to the beginning of next packet.
        subsstringPointer = subsstringPointer + 19;
    }
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

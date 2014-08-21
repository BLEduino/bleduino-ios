//
//  ConsoleTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/16/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "ConsoleTableViewController.h"
#import "ConsoleCell.h"
#import "ConsoleEntries.h"
#include <tgmath.h>

@interface ConsoleTableViewController ()
@end


@implementation ConsoleTableViewController

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
    
    [self setConsoleTextField];
    
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
    
    self.iOSTextColor = [UIColor colorWithRed:77/255.0f green:0/255.0f blue:158/255.0f alpha:1];
    self.bleduinoTextColor = lightBlue;
    
    //Dummy TableView footer/header for scrolling purposes.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
    
    //Setup comunication.
    [self setupConsole];
    
    //Setup delegate
    self.consoleTextField.delegate = self;
    
    //Setup data model
    self.entries = [[NSMutableArray alloc] initWithCapacity:10];
}


- (void)setupConsole
{
    //Set manager and service
    BDLeDiscoveryManager *manager = [BDLeDiscoveryManager sharedLeManager];
    manager.delegate = self;
    
    //Setup console hub.
    self.consoleHub = [[NSMutableArray alloc] initWithCapacity:manager.connectedBleduinos.count];
    
    for(CBPeripheral *bleduino in manager.connectedBleduinos)
    {
        BDUart *newConsole = [[BDUart alloc] initWithPeripheral:bleduino delegate:self];
        [newConsole subscribeToStartReceivingMessages];
        [self.consoleHub addObject:newConsole];
    }
}

- (void)setConsoleTextField
{
    //Create footer view.
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    footerView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    //Set border.
    CALayer *TopBorder = [CALayer layer];
    TopBorder.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 0.70f);
    TopBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [footerView.layer addSublayer:TopBorder];
    
    //Add subviews.
    UITextField *consoleTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 7, 280, 30)];
    self.consoleTextField = consoleTextField;

    //Configure
    [consoleTextField becomeFirstResponder];
    [consoleTextField setBorderStyle:UITextBorderStyleNone];
    [consoleTextField setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [consoleTextField setClearButtonMode:UITextFieldViewModeAlways];
    [consoleTextField setReturnKeyType:UIReturnKeySend];
    consoleTextField.placeholder = @"Enter text here...";
    consoleTextField.enablesReturnKeyAutomatically = YES;
    consoleTextField.delegate = self;
    [footerView addSubview:consoleTextField];
    footerView.tag = 2013;
    
    //Set new footer view.
    [self.navigationController.view addSubview:footerView];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Setup text.
    ConsoleEntries *entry = (ConsoleEntries *)[self.entries objectAtIndex:indexPath.row];
    UIColor *textColor = (entry.isBLEduino)?self.bleduinoTextColor:self.iOSTextColor;
    NSString *sender = (entry.isBLEduino)?@"bleduino: ":@"ios: ";
    NSString *finalText = [sender stringByAppendingString:entry.text];
    NSDictionary *textAttributes = @{NSForegroundColorAttributeName:textColor};
    
    //Setup cell.
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"ConsoleCell" forIndexPath:indexPath];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.textLabel setNumberOfLines:0];
    
    //Setup attributed text.
    NSMutableAttributedString *finalAttributedText = [[NSMutableAttributedString alloc] initWithString:finalText];
    [finalAttributedText addAttributes:textAttributes range:NSMakeRange(0, (sender.length))];
    [finalAttributedText addAttribute:NSFontAttributeName
                                value:[UIFont systemFontOfSize:16.0f]
                                range:NSMakeRange(0, entry.text.length)];
    cell.textLabel.attributedText = finalAttributedText;
    cell.detailTextLabel.text = entry.timeString;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ConsoleEntries *entry = [self.entries objectAtIndex:indexPath.row];
    NSString *sender = (entry.isBLEduino)?@"bleduino: ":@"ios: ";
    NSString *finalText = [sender stringByAppendingString:entry.text];
    CGSize labelSize = [entry.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}];
    CGSize timeLabelSize = [entry.timeString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}];
    
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect rect = [finalText boundingRectWithSize:CGSizeMake(280, labelSize.width)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}
                                           context:ctx];
    
    CGFloat height = ceilf(rect.size.height + timeLabelSize.height) + 5.0f;
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.entries.count;
}

//Send data.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    ConsoleEntries *entry = [[ConsoleEntries alloc] init];
    entry.text = textField.text;
    entry.time = [NSDate date];
    entry.isBLEduino = NO;
    
    //Send data to BLEduinos.
    for(BDUart *console in self.consoleHub)
    {
        [console writeMessage:entry.text];
    }
    
    //Add entry to model and tableview.
    [self.entries insertObject:entry atIndex:self.entries.count];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.entries.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    
    //Scroll to make last entry visible.
    [self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame animated:YES];
    
    self.consoleTextField.text = @"";
    
    return NO;
}

//Receive data.
- (void)uartService:(BDUart *)service didReceiveMessage:(NSString *)message error:(NSError *)error
{
    ConsoleEntries *entry = [[ConsoleEntries alloc] init];
    entry.text = message;
    entry.time = [NSDate date];
    entry.isBLEduino = YES;
    
    //Add entry to model and tableview.
    [self.entries insertObject:entry atIndex:self.entries.count];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.entries.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    
    //Scroll to make last entry visible.
    [self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame animated:YES];
}

- (IBAction)dismissModule:(id)sender
{
    [self.delegate consoleControllerDismissed:self];
}

- (IBAction)clear:(id)sender
{
    //Remove all rows.
    NSMutableArray *indexes = [[NSMutableArray alloc] initWithCapacity:self.entries.count];
    for(int i = 0; i < self.entries.count; i++)
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        [indexes addObject:index];
    }
    [self.entries removeAllObjects];
    [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationTop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)calculateLabelHeightForString:(NSString *)text
{
    CGSize labelSize = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}];
    
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(280, labelSize.width)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}
                                     context:ctx];
    
    return rect.size.height;
}

#pragma mark -
#pragma mark - Subscribe Delegate
/****************************************************************************/
/*                            Subscribe Delegate                            */
/****************************************************************************/
- (void) didSubscribeToReceiveMessagesFor:(BDUart *)service error:(NSError *)error
{
    NSLog(@"Subscribed to UART service from Console.");
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

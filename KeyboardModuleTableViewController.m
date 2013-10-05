//
//  KeyboardModuleTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "KeyboardModuleTableViewController.h"
#import "UARTService.h"
#import "LeDiscoveryManager.h"

@interface KeyboardModuleTableViewController ()

@end

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

    UIBarButtonItem *dissmissButton = [[UIBarButtonItem alloc] initWithTitle:@"Modules" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModule:)];
    self.navigationItem.leftBarButtonItem = dissmissButton;
    
    self.messageView.delegate = self;
    [self.messageView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        LeDiscoveryManager *leManager = [LeDiscoveryManager sharedLeManager];
        CBPeripheral *bleduino = [leManager.connectedBleduinos lastObject];
        
        NSString *message = self.messageView.text;
        UARTService *messageService = [[UARTService alloc] initWithPeripheral:bleduino controller:self];
        [messageService writeMessage:message];
    }
    return YES;
}

- (void)dismissModule:(id)sender
{
    [self.delegate keyboardModuleTableViewControllerDismissed:self];
}

@end

//
//  KeyboardModuleTableViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "KeyboardModuleTableViewController.h"
#import "UARTService.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        NSString *message = self.messageView.text;
        UARTService *messageService = [[UARTService alloc] initWithPeripheral:nil controller:self];
        [messageService writeMessage:message];
    }
    return YES;
}

- (void)dismissModule:(id)sender
{
    [self.delegate keyboardModuleTableViewControllerDismissed:self];
}

@end

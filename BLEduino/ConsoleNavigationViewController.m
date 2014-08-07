//
//  ConsoleNavigationViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/4/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "ConsoleNavigationViewController.h"

@interface ConsoleNavigationViewController ()

@end

@implementation ConsoleNavigationViewController

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
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    UIView *consoleTextFieldView = [self.view viewWithTag:2013];
    
    [UIView beginAnimations:@"Remove TextField" context:nil];
    [consoleTextFieldView removeFromSuperview];
    [UIView commitAnimations];
}

- (void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    CGFloat keyboardHeight =  keyboardFrame.size.height;
    
    //Update textfield location.
    UIView *consoleTextFieldView = [self.view viewWithTag:2013];
    CGFloat height = consoleTextFieldView.frame.size.height;
    CGFloat width = consoleTextFieldView.frame.size.width;
    CGFloat y = self.view.frame.size.height - keyboardHeight - height;
    [consoleTextFieldView setFrame:CGRectMake(0, y, width, height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

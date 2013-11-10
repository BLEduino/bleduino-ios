//
//  ModulesCollectionViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "ModulesCollectionViewController.h"
#import "ModuleCollectionViewCell.h"
#import "KeyboardModuleTableViewController.h"
#import "LeDiscoveryTableViewController.h"

@interface ModulesCollectionViewController ()

@end
    
@implementation ModulesCollectionViewController
@synthesize modules;

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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.modules = @[@"LCD",@"Keyboard",@"Game Controller",@"R/C Car",@"Power Relay",@"LED",@"Notifications",@"BLE Bridge"];
    self.modulesImages = @[@"lcd.png",@"keyboard.png",@"game-controller.png", @"rc-car.png",@"power-relay.png", @"led.png", @"notifications.png",@"ble-bridge.png"];
    
    //Set BLE navigation.
    [self.navigationItem.leftBarButtonItem setTarget:self];
    [self.navigationItem.leftBarButtonItem setAction:@selector(presentConnectionManager:)];

    //Set appareance.
    UIColor *darkBlue = [UIColor colorWithRed:50/255.0 green:81/255.0 blue:147/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = darkBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.modules.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ModuleCollectionViewCell *moduleCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ModuleCell" forIndexPath:indexPath];
    
    UIImage *image = [[UIImage alloc] init];
    image = [UIImage imageNamed:[self.modulesImages objectAtIndex:indexPath.row]];
    
    moduleCell.moduleImage.image = image;
    moduleCell.moduleName.text = [self.modules objectAtIndex:indexPath.row];
    return moduleCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger module = indexPath.item;
    
    switch (module) {
        case 0:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
    }
}

- (void)presentConnectionManager:(id)sender
{
    [self performSegueWithIdentifier:@"ConnectionManagerSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"KeyboardModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        KeyboardModuleTableViewController *keyboardController = [[navigationController viewControllers] objectAtIndex:0];
        keyboardController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ConnectionManagerSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        LeDiscoveryTableViewController *connectionController = [[navigationController viewControllers] objectAtIndex:0];
        connectionController.delegate = self;
    }
}

#pragma mark -
#pragma mark - Modules Dismiss Delegates
/****************************************************************************/
/*                         Modules Dismiss' Delegate                        */
/****************************************************************************/
- (void) keyboardModuleTableViewControllerDismissed:(KeyboardModuleTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) leDiscoveryTableViewControllerDismissed:(LeDiscoveryTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

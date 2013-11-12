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

#import "NotificationService.h"
#import "RESideMenu.h"


@implementation ModulesCollectionViewController

#pragma mark -
#pragma mark - Setup
/****************************************************************************/
/*                Module CollectionViewController Setup                     */
/****************************************************************************/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)showMenu
{
    [self.sideMenuViewController presentMenuViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set modules' data.
    self.modules = @[@"LCD",@"Keyboard",@"Game Controller",@"R/C Car",@"Power Relay",@"LED",
                     @"Notifications",@"BLE Bridge"];
    
//    self.modulesImages = @[@"lcd.png",@"keyboard.png",@"game-controller.png",
//                           @"rc-car.png",@"power-relay.png", @"led.png",
//                           @"notifications.png",@"ble-bridge.png"];
    
    self.modulesImages = @[@"0.png",@"1.png",@"2.png",
                           @"3",@"4.png", @"5.png",
                           @"6.png",@"7.png"];
    
    //Set services that run in the background.
    self.bleBridge = [[BleBridgeService alloc] init];
    
    //Set BLE navigation.
    [self.navigationItem.leftBarButtonItem setTarget:self];
//    [self.navigationItem.leftBarButtonItem setAction:@selector(presentConnectionManager:)];

    //Set appareance.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIColor *darkBlue = [UIColor colorWithRed:50/255.0 green:81/255.0 blue:147/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = darkBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Collection View Data Source
/****************************************************************************/
/*                        UICollectionview Data Source                      */
/****************************************************************************/

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

#pragma mark -
#pragma mark - Collection View Delegate
/****************************************************************************/
/*                        UICollectionview Delegate                         */
/****************************************************************************/

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger module = indexPath.item;
    
    switch (module) {
        case 0:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 4:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 5:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 6:
            //Toggle notification service.
            if(self.notifications.isListening)
            {
                [self.notifications stopListening];
            }
            else
            {
                [self.notifications startListening];
            }
            break;
            
        case 7:
            //Toggle BLE bridge service.
            if(self.bleBridge.isOpen)
            {
                [self.bleBridge closeBridge];
            }
            else
            {
                [self.bleBridge openBridge];
            }
            break;
            
        case 8:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 9:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 10:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 11:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 12:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
    }
}

#pragma mark -
#pragma mark - Collection Cell Details - Flow Layout Delegate
/****************************************************************************/
/*                          Flow Layour Delegate                            */
/****************************************************************************/

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(120, 120);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(15, 25, 15, 25);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(10, -20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(10, 10);
}

#pragma mark -
#pragma mark - Modules Segues
/****************************************************************************/
/*                              Modules Segues                              */
/****************************************************************************/

//- (void)presentConnectionManager:(id)sender
//{
//    [self performSegueWithIdentifier:@"ConnectionManagerSegue" sender:self];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"KeyboardModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        KeyboardModuleTableViewController *keyboardController = [[navigationController viewControllers] objectAtIndex:0];
        keyboardController.delegate = self;
    }
//    else if ([segue.identifier isEqualToString:@"ConnectionManagerSegue"])
//    {
//        UINavigationController *navigationController = segue.destinationViewController;
//        LeDiscoveryTableViewController *connectionController = [[navigationController viewControllers] objectAtIndex:0];
//        connectionController.delegate = self;
//    }
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

//
//  ModulesCollectionViewController.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "ModulesCollectionViewController.h"
#import "ModuleCollectionViewCell.h"
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

//Present admin (side) navigation menu.
- (IBAction)showMenu
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.sideMenuViewController presentMenuViewController];
}

//Show status bar after hiding the admin (side) nagivation menu.
- (void)showStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set modules' data.
    self.modules = @[@"LCD",@"Keyboard",@"Game Controller",@"R/C Car",@"Power Relay",@"LED",
                     @"Notifications",@"BLE Bridge"];
    
    self.modulesImages = @[@"lcd-b.png",@"keyboard-b.png",@"controller-b.png",
                           @"rc-b.png",@"power-b2.png", @"led-b3.png",
                           @"notifications-b.png",@"bridge-b.png"];
    
    //Set services that run in the background.
    self.notifications = [[NotificationService alloc] init];
    self.bleBridge = [[BleBridgeService alloc] init];
    
    //Set appareance.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIColor *lightBlue = [UIColor colorWithRed:38/255.0 green:109/255.0 blue:235/255.0 alpha:1.0];

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = lightBlue;
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
    
//    //Set aspect ratio.
//    switch (indexPath.row) {
//        case 0:
//            UIImageView *newImageView = [UIImageView ui]
//            moduleCell.moduleImage.frame = CGRectMake(32, 42, 56, 36);
//            break;
//        case 1:
//            moduleCell.moduleImage.frame = CGRectMake(32, 38, 56, 44);
//            break;
//        case 2:
//            moduleCell.moduleImage.frame = CGRectMake(32, 38, 56, 44);
//            break;
//        case 3:
//            moduleCell.moduleImage.frame = CGRectMake(32, 35, 56, 50);
//            break;
//        case 4:
//            moduleCell.moduleImage.frame = CGRectMake(32, 38, 56, 44);
//            break;
//        case 5:
//            moduleCell.moduleImage.frame = CGRectMake(42, 32, 36, 56);
//            break;
//        case 6:
//            moduleCell.moduleImage.frame = CGRectMake(32, 34, 56, 52);
//            break;
//        case 7:
//            moduleCell.moduleImage.frame = CGRectMake(32, 32, 56, 56);
//            break;
//    }
    
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
            [self performSegueWithIdentifier:@"LCDModuleSegue" sender:self];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"KeyboardModuleSegue" sender:self];
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"GameControllerModuleSegue" sender:self];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"RadioControlledModuleSegue" sender:self];
            break;
            
        case 4:
            [self performSegueWithIdentifier:@"PowerRelayModuleSegue" sender:self];
            break;
            
        case 5:
            [self performSegueWithIdentifier:@"LEDModuleSegue" sender:self];
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
            //Extra Module
            break;
            
        case 9:
            //Extra Module
            break;
            
        case 10:
            //Extra Module
            break;
            
        case 11:
            //Extra Module
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"LCDModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        LCDTableViewController *lcdController = [[navigationController viewControllers] objectAtIndex:0];
        lcdController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"KeyboardModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        KeyboardModuleTableViewController *keyboardController = [[navigationController viewControllers] objectAtIndex:0];
        keyboardController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"GameControllerModuleSegue"])
    {
        GameControllerViewController *gameController = segue.destinationViewController;
        gameController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"RadioControlledModuleSegue"])
    {
        RadioControlledViewController *rcController = segue.destinationViewController;
        rcController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"PowerRelayModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        PowerRelayViewController *powerRelayController = [[navigationController viewControllers] objectAtIndex:0];
        powerRelayController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"LEDModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        LEDModuleTableViewController *ledController = [[navigationController viewControllers] objectAtIndex:0];
        ledController.delegate = self;
    }
}

#pragma mark -
#pragma mark - Modules Dismiss Delegates
/****************************************************************************/
/*                         Modules Dismiss' Delegate                        */
/****************************************************************************/
- (void)lcdModuleTableViewControllerDismissed:(LCDTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)keyboardModuleTableViewControllerDismissed:(KeyboardModuleTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)gameControllerModuleViewControllerDismissed:(GameControllerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }];
}

- (void)radioControlledModuleViewControllerDismissed:(RadioControlledViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }];
}

- (void)powerRelayModulViewControllerDismissed:(PowerRelayViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)ledModuleTableViewControllerDismissed:(LEDModuleTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end

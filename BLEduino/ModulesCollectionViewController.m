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
    
    //Set services that run in the background.
    self.notifications = [BDNotificationService sharedListener];
    self.bleBridge = [BDBleBridgeService sharedBridge];
    
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
    return 10;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    
    switch (indexPath.row) {
        case 0:
            //LCD Module
            cellIdentifier = @"LCDModuleCell";
            break;
        case 1:
            //Keyboard Module
            cellIdentifier = @"KeyboardModuleCell";
            break;
        case 2:
            //Game Controller Module
            cellIdentifier = @"GameControllerModuleCell";
            break;
        case 3:
            //Radio Controlled Module
            cellIdentifier = @"RadioControlledModuleCell";
            break;
        case 4:
            //Power Relay Module
            cellIdentifier = @"PowerRelayModuleCell";
            break;
        case 5:
            //LED Module
            cellIdentifier = @"LEDModuleCell";
            break;
        case 6:
            //Notifications Module
            cellIdentifier = @"NotificationsModuleCell";
            break;
        case 7:
            //BleBridge Module
            cellIdentifier = @"BleBridgeModuleCell";
            break;
        case 8:
            //Firmata Module
            cellIdentifier = @"FirmataModuleCell";
            break;
        case 9:
            //Sequencer Module
            cellIdentifier = @"SequencerModuleCell";
            break;
    }
    
    ModuleCollectionViewCell *moduleCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                              forIndexPath:indexPath];
    
    //Setup dismiss button.
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.frame = CGRectMake(34, 20, 14, 28);
    [dismissButton setImage:[UIImage imageNamed:@"arrow-left.png"] forState:UIControlStateNormal];
    [dismissButton addTarget:self
                      action:@selector(dismissModule)
            forControlEvents:UIControlEventTouchUpInside];
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
                
                //Update icon.
                ModuleCollectionViewCell *cell = (ModuleCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell.moduleIcon setImage:[UIImage imageNamed:@"notifications.png"] forState:UIControlStateNormal];
            }
            else
            {
                [self.notifications startListening];
                
                //Update icon.
                ModuleCollectionViewCell *cell = (ModuleCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell.moduleIcon setImage:[UIImage imageNamed:@"notifications-s.png"] forState:UIControlStateNormal];
            }
            break;
            
        case 7:
            //Toggle BLE bridge service.
            if(self.bleBridge.isOpen)
            {
                [self.bleBridge closeBridge];
                
                //Update icon.
                ModuleCollectionViewCell *cell = (ModuleCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell.moduleIcon setImage:[UIImage imageNamed:@"bridge.png"] forState:UIControlStateNormal];
            }
            else
            {
                [self.bleBridge openBridge];
                
                //Update icon.
                ModuleCollectionViewCell *cell = (ModuleCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [cell.moduleIcon setImage:[UIImage imageNamed:@"bridge-s.png"] forState:UIControlStateNormal];
            }
            break;
            
        case 8:
            [self performSegueWithIdentifier:@"FirmataModuleSegue" sender:self];
            break;
            
        case 9:
            [self performSegueWithIdentifier:@"SequencerModuleSegue" sender:self];
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
    
    return UIEdgeInsetsMake(0, 25, 0, 25);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(10, -15);
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
    else if([segue.identifier isEqualToString:@"FirmataModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        FirmataTableViewController *firmataController = [[navigationController viewControllers] objectAtIndex:0];
        firmataController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"SequencerModuleSegue"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        SequencerTableViewController *sequencerController = [[navigationController viewControllers] objectAtIndex:0];
        sequencerController.delegate = self;
    }
}

#pragma mark -
#pragma mark - Modules Dismiss Delegates
/****************************************************************************/
/*                         Modules Dismiss' Delegate                        */
/****************************************************************************/
- (void)sequencerTableViewControllerDismissed:(SequencerTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)firmataTableViewControllerDismissed:(FirmataTableViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

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

//
//  AppDelegate.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 9/24/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "AppDelegate.h"
#import "BDLeDiscoveryManager.h"
#import "BDNotificationService.h"
#import "PowerSwitchButtonView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Launch LeDiscovery manager.
    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    
    //Configure settings.
    //Is this the first launch ever of this application?
    //Verify if keys exists prior to this launch.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    //Scanning and connection
    if([defaults objectForKey:SETTINGS_SCAN_ONLY_BLEDUINO] == nil ||
       [defaults objectForKey:SETTINGS_NOTIFY_CONNECT] == nil ||
       [defaults objectForKey:SETTINGS_NOTIFY_DISCONNECT] == nil)
    {
        leManager.scanOnlyForBLEduinos = YES;
        leManager.notifyConnect = NO;
        leManager.notifyDisconnect = YES;
        
        [defaults setBool:YES forKey:SETTINGS_SCAN_ONLY_BLEDUINO];
        [defaults setBool:YES forKey:SETTINGS_NOTIFY_DISCONNECT];
        [defaults setBool:NO forKey:SETTINGS_NOTIFY_CONNECT];
    }
    
    //Modules
    if([defaults objectForKey:SETTINGS_LCD_TOTAL_CHARS] == nil ||
       [defaults objectForKey:SETTINGS_POWERRELAY_PIN_NUMBER] == nil ||
       [defaults objectForKey:SETTINGS_POWERRELAY_STATUS_COLOR] == nil)
    {
        [defaults setInteger:32 forKey:SETTINGS_LCD_TOTAL_CHARS];
        [defaults setInteger:11 forKey:SETTINGS_POWERRELAY_PIN_NUMBER];
        [defaults setInteger:PowerSwitchStatusColorGreenRed forKey:SETTINGS_POWERRELAY_STATUS_COLOR];
    }
    [defaults synchronize];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //Verify who is sending local notification.
    NSString *serviceUUIDString = [notification.userInfo objectForKey:@"service"];
    NSString *connectNotification = [notification.userInfo objectForKey:@"connect"];
    NSString *disconnectNotification = [notification.userInfo objectForKey:@"disconnect"];
    

    if(serviceUUIDString)
    {
        //Notification Service?
        if([serviceUUIDString isEqual:kNotificationAttributesCharacteristicUUIDString])
        {
            NSString *message = [notification.userInfo objectForKey:@"message"];
            NSString *title   = [notification.userInfo objectForKey:@"title"];
            
            
            UIAlertView *notificationAlert = [[UIAlertView alloc]initWithTitle:title
                                                                       message:message
                                                                      delegate:nil
                                                             cancelButtonTitle:@"Close"
                                                             otherButtonTitles:nil];
            
            [notificationAlert show];
        }
    }

    else if(connectNotification || disconnectNotification)
    {
        NSString *message = [notification.userInfo objectForKey:@"message"];
        NSString *title   = [notification.userInfo objectForKey:@"title"];
        
        
        UIAlertView *notificationAlert = [[UIAlertView alloc]initWithTitle:title
                                                                   message:message
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Close"
                                                         otherButtonTitles:nil];
        
        [notificationAlert show];
    }

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

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
//    BDLeDiscoveryManager *leManager = [BDLeDiscoveryManager sharedLeManager];
    
    //FIXME: MAKE SURE MANAGER TRIES TO RECONNECT AFTER LOSING CONNECTION.
    //FIXME: /s/projects/748777/stories/57861620
    
    //Configure settings.
    //Is this the first launch ever of this application?
    //Verify if keys exists prior to this launch.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Global
    if([defaults doubleForKey:WRITE_TIME_CAP])
    {
        [defaults setDouble:200 forKey:WRITE_TIME_CAP];
    }
    
//    //Scanning and connection
//    if([defaults objectForKey:SETTINGS_SCAN_ONLY_BLEDUINO] == nil ||
//       [defaults objectForKey:SETTINGS_NOTIFY_CONNECT] == nil ||
//       [defaults objectForKey:SETTINGS_NOTIFY_DISCONNECT] == nil)
//    {
//        leManager.scanOnlyForBLEduinos = YES;
//        leManager.notifyConnect = NO;
//        leManager.notifyDisconnect = YES;
//        
//        [defaults setBool:YES forKey:SETTINGS_SCAN_ONLY_BLEDUINO];
//        [defaults setBool:YES forKey:SETTINGS_NOTIFY_DISCONNECT];
//        [defaults setBool:NO forKey:SETTINGS_NOTIFY_CONNECT];
//    }
    
    //Modules
    if([defaults objectForKey:SETTINGS_LCD_TOTAL_CHARS] == nil ||
       [defaults objectForKey:SETTINGS_POWERRELAY_PIN_NUMBER] == nil ||
       [defaults objectForKey:SETTINGS_POWERRELAY_STATUS_COLOR] == nil)
    {
        [defaults setInteger:32 forKey:SETTINGS_LCD_TOTAL_CHARS];
        
        [defaults setInteger:9 forKey:SETTINGS_POWERRELAY_PIN_NUMBER];
        [defaults setInteger:PowerSwitchStatusColorGreenRed forKey:SETTINGS_POWERRELAY_STATUS_COLOR];
        
        [defaults setBool:NO forKey:SETTINGS_PROXIMITY_DISTANCE_ALERT_ENABLED];
        [defaults setBool:YES forKey:SETTINGS_PROXIMITY_DISTANCE_FORMAT_FT];
    }
    
    //Firmata
    if([defaults objectForKey:FIRMATA_PIN0_STATE] == nil)
    {
        NSInteger defaultState = 1;
        [defaults setInteger:defaultState forKey:FIRMATA_PIN0_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN1_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN2_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN3_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN4_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN5_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN6_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN7_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN8_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN9_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN10_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN13_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PINA0_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PINA1_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PINA2_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PINA3_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PINA4_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PINA5_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN_MISO_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN_MOSI_STATE];
        [defaults setInteger:defaultState forKey:FIRMATA_PIN_SCK_STATE];
    }
    
    if([defaults objectForKey:FIRMATA_PIN0_STATE_TYPES] == nil)
    {
        NSInteger digital = 0;
        NSInteger analog = 1;
        NSInteger pwm = 2;
        NSInteger allTypes = 3;
        
        [defaults setInteger:digital  forKey:FIRMATA_PIN0_STATE_TYPES];
        [defaults setInteger:digital  forKey:FIRMATA_PIN1_STATE_TYPES];
        [defaults setInteger:digital  forKey:FIRMATA_PIN2_STATE_TYPES];
        [defaults setInteger:pwm      forKey:FIRMATA_PIN3_STATE_TYPES];
        [defaults setInteger:analog   forKey:FIRMATA_PIN4_STATE_TYPES];
        [defaults setInteger:pwm      forKey:FIRMATA_PIN5_STATE_TYPES];
        [defaults setInteger:allTypes forKey:FIRMATA_PIN6_STATE_TYPES];
        [defaults setInteger:digital  forKey:FIRMATA_PIN7_STATE_TYPES];
        [defaults setInteger:analog   forKey:FIRMATA_PIN8_STATE_TYPES];
        [defaults setInteger:allTypes forKey:FIRMATA_PIN9_STATE_TYPES];
        [defaults setInteger:allTypes forKey:FIRMATA_PIN10_STATE_TYPES];
        [defaults setInteger:pwm      forKey:FIRMATA_PIN13_STATE_TYPES];
        [defaults setInteger:analog   forKey:FIRMATA_PINA0_STATE_TYPES];
        [defaults setInteger:analog   forKey:FIRMATA_PINA1_STATE_TYPES];
        [defaults setInteger:analog   forKey:FIRMATA_PINA2_STATE_TYPES];
        [defaults setInteger:analog   forKey:FIRMATA_PINA3_STATE_TYPES];
        [defaults setInteger:analog   forKey:FIRMATA_PINA4_STATE_TYPES];
        [defaults setInteger:analog   forKey:FIRMATA_PINA5_STATE_TYPES];
        [defaults setInteger:digital  forKey:FIRMATA_PIN_MISO_STATE];
        [defaults setInteger:digital  forKey:FIRMATA_PIN_MOSI_STATE];
        [defaults setInteger:digital  forKey:FIRMATA_PIN_SCK_STATE];
    }
    
    //Proximity
    if([defaults objectForKey:PROXIMITY_FIRST_CALIBRATION] == nil)
    {
        [defaults setBool:YES forKey:PROXIMITY_FIRST_CALIBRATION];
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
    NSString *proximityNotification = [notification.userInfo objectForKey:@"ProximityModule"];
    

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
    else if (proximityNotification)
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

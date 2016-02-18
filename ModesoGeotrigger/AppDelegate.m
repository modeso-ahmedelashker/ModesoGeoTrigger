//
//  AppDelegate.m
//  ModesoGeotrigger
//
//  Created by Modeso on 1/29/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import "AppDelegate.h"
#import <GeotriggerSDK/GeotriggerSDK.h>

NSString *kClientId = @"Y7LJi20LkgmnshCr";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // --------------------------- GeoTrigger Manager ---------------------------------
    // Enable debug logs to the console. This spits out a lot of logs so you probably don't want to do this in a release build, but it is good for helping track down any problems you may encounter.
    [AGSGTGeotriggerManager setLogLevel:AGSGTLogLevelDebug];
    
    [AGSGTGeotriggerManager setupWithClientId:kClientId isProduction:NO tags:nil isOffline:NO completion:^(NSError *error)
     {
         if (error != nil)
         {
             NSLog(@"Geotrigger Service setup encountered error: %@", error);
         }
         else
         {
             NSLog(@"Geotrigger Service ready to go!");
         }
     }];
    ;
    
    // If we were launched from a push notification, send the payload to the Geotrigger Manager
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] != nil)
    {
        [AGSGTGeotriggerManager handlePushNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] showAlert:YES];
    }
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"registerForRemoteNotificationsSuccess" object:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Failed to register for remote notifications with Apple: %@", [error debugDescription]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"registerForRemoteNotificationsFailure" object:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSMutableDictionary *receivedTriggerData = userInfo[@"data"];
    
    //self.lvc.mvc.cmv.firedDict = [NSMutableDictionary dictionaryWithDictionary:receivedTriggerData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationReceived" object:receivedTriggerData];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

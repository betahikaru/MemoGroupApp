//
//  MGAppDelegate.m
//  MemoGroup
//
//  Created by 鈴木 光 on 2013/01/22.
//  Copyright (c) 2013年 鈴木 光. All rights reserved.
//

#import "MGAppDelegate.h"

#import "MGViewController.h"
#import "MemoGroupStore.h"

@implementation MGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Test Flight
    [TestFlight takeOff:@"64c37dc317c3c17d4493f6ef17a685d5_MTc5OTU1MjAxMy0wMS0yNyAxMjozMToxNi4wNzI0MjE"];
    
#define TESTING 0
#ifdef TESTING
#pragma GCC diagnostic ignored "-Wdeprecated-declarations" // 非推薦メソッドの警告を無視
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#pragma GCC diagnostic warning "-Wdeprecated-declarations" // 非推薦メソッドの警告を再開
    [TestFlight passCheckpoint:@"didFinishLaunchingWithOptions"];  // チェックポイントの追加
#endif
    
    
    // Initialize App
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[MGViewController alloc] init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    return YES;
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
    
    
    // アプリケーションがバックグラウンドに入る前に、データを保存する。
    //    [[MemoGroupStore defaultStore] saveChanges];
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

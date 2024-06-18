//
//  UAppDelegate.m
//  UIdemo
//
//  Created by 82560897 on 05/27/2024.
//  Copyright (c) 2024 82560897. All rights reserved.
//

#import "UAppDelegate.h"
#import "UViewController.h"
#import "CViewController.h"
#import "MViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation UAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // 创建一个 CTTelephonyNetworkInfo 实例
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    // 获取当前的 CTCarrier 对象
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    // 打印运营商信息
    if (carrier != nil) {
        NSLog(@"Carrier Name: %@", [carrier carrierName] ?: @"Unknown");
        NSLog(@"Mobile Country Code (MCC): %@", [carrier mobileCountryCode] ?: @"Unknown");
        NSLog(@"Mobile Network Code (MNC): %@", [carrier mobileNetworkCode] ?: @"Unknown");
        NSLog(@"ISO Country Code: %@", [carrier isoCountryCode] ?: @"Unknown");
        NSLog(@"Allows VOIP: %@", [carrier allowsVOIP] ? @"YES" : @"NO");
    } else {
        NSLog(@"Carrier information is not available.");
    }

    
    UIViewController *homeVC = [[UViewController alloc] init];;
    homeVC.title = @"table";
    UINavigationController *NaviVC1 = [[UINavigationController alloc] initWithRootViewController:homeVC];
    UITabBarItem *item0 = [[UITabBarItem alloc] initWithTitle:homeVC.title image:[UIImage imageNamed:@"img1"] selectedImage:[UIImage imageNamed:@"img2"]];
    NaviVC1.tabBarItem = item0;
    
    UIViewController *contactVC = [[CViewController alloc] init];
    contactVC.title = @"collection";
    UINavigationController *NaviVC2 = [[UINavigationController alloc] initWithRootViewController:contactVC];
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:contactVC.title image:[UIImage imageNamed:@"img3"] selectedImage:[UIImage imageNamed:@"img4"]];
    NaviVC2.tabBarItem = item1;
    
    UIViewController *VC = [[MViewController alloc] init];
    VC.title = @"layout";
    UINavigationController *NaviVC3 = [[UINavigationController alloc] initWithRootViewController:VC];
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:VC.title image:[UIImage imageNamed:@"img1"] selectedImage:[UIImage imageNamed:@"img2"]];
    NaviVC3.tabBarItem = item2;
    
    UITabBarController *tabBarVC = [[UITabBarController alloc] init];
    tabBarVC.viewControllers = @[NaviVC1, NaviVC2,NaviVC3];
    tabBarVC.selectedViewController = NaviVC1;
    
//    tabBarVC.tabBar.backgroundImage = [UIImage imageNamed:@"image"];
    //设置选中时文字颜色
    tabBarVC.tabBar.tintColor = [UIColor colorWithRed:254/255.0 green:234/255.0 blue:42/255.0 alpha:1.0];
    
    //选中时使用原图片
    for (UITabBarItem *item in tabBarVC.tabBar.items) {
        UIImage *image = item.selectedImage;
        UIImage *correctImage =[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = correctImage;
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = tabBarVC;
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

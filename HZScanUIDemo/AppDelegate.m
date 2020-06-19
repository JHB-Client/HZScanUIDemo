//
//  AppDelegate.m
//  HZScanUIDemo
//
//  Created by admin on 2019/11/21.
//  Copyright © 2019 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window.rootViewController = navCtr;
    [self.window makeKeyAndVisible];
    return YES;
}


@end

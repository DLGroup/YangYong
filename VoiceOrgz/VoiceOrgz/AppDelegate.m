//
//  AppDelegate.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 2/25/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "AppDelegate.h"
#import "DashBoardViewController.h"
#import "SharedObj.h"
#import "GlobalObj.h"
#import "SideshowView.h"
#import "VoiceMainView.h"
@implementation AppDelegate

@synthesize nav=_nav;


- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if ([viewController isMemberOfClass:[SideshowView class]]){
        [navigationController.navigationBar setBackgroundImage:
         [GlobalObj getImageFromFile:@"nav_bar.png"] forBarMetrics:UIBarMetricsDefault ];
        
        //navigationController.navigationBar.alpha = 0.65f;
    }
    else{
        [navigationController.navigationBar setBackgroundImage:
         [GlobalObj getImageFromFile:@"navigation_bar_background.png"] forBarMetrics:UIBarMetricsDefault ];
        
        navigationController.navigationBar.alpha = 1.0f;
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSMutableData *data=[[NSMutableData alloc]
                         initWithContentsOfFile:[NSHomeDirectory()
                                                 stringByAppendingPathComponent:@"Documents/Data/sharedObj"]];
    
    if(data){
        NSKeyedUnarchiver *uar=[[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        _sharedObj = [uar decodeObjectForKey:@"sharedObj"];
        [uar finishDecoding];
    }
    
    DashBoardViewController *dashBoardViewController=[[DashBoardViewController alloc] initWithNibName:@"DashBoardViewController" bundle:nil];
    
    _nav = [[UINavigationController alloc] initWithRootViewController:dashBoardViewController];
    [_nav.navigationBar setBackgroundImage:[GlobalObj getImageFromFile:@"navigation_bar_background.png"] forBarMetrics:UIBarMetricsDefault ];
    _nav.delegate=self;
    
    self.window.rootViewController=_nav;
    self.window.backgroundColor = [UIColor whiteColor];
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
    [SharedObj save];

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
    self.nav=nil;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    NSLog(@"app memory warning");
    [_nav popToRootViewControllerAnimated:NO];
    [GlobalObj refreshCache];
}
@end





//
//  AppDelegate.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@property (strong, nonatomic) UIView *progressView;
- (void)createProgressView;

@end

@implementation AppDelegate
@synthesize progressHUD = _progressHUD;
@synthesize progressView = _progressView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRollID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRollID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)createProgressView
{
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 350.0f, 320.0f, 70.0f)];
    [self.window addSubview:self.progressView];
}

- (void)addHUDWithMessage:(NSString *)message
{
    // Remove HUD (if it exists)
    [self removeHUD];
    
    // Create new view to hold HUD in window
    [self createProgressView];
    
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.progressView animated:YES];
    self.progressHUD.mode = MBProgressHUDModeText;
    self.progressHUD.labelText = message;
    self.progressHUD.labelFont = [UIFont fontWithName:@"Ubuntu-Bold" size:12.0f];
    
}

- (void)removeHUD
{
    // If an older progressHUD exists, remove it to make room for the new HUD
    [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
    [self.progressView removeFromSuperview];
    
}

@end

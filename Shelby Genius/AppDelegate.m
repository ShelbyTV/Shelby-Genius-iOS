//
//  AppDelegate.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@property (strong, nonatomic) UIView *progressView;

- (void)customization;
- (void)createProgressView;

@end

@implementation AppDelegate
@synthesize window;
@synthesize searchViewController;
@synthesize searchNavigationController;
@synthesize progressHUD = _progressHUD;
@synthesize progressView = _progressView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Initialize UIWindow's rootViewController
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController_iPhone" bundle:nil];
    self.searchNavigationController = [[UINavigationController alloc] initWithRootViewController:self.searchViewController];
    self.window.rootViewController = searchNavigationController;
    
    // Appearance Proxies and General Customization
    [self customization];
    
    [self.window makeKeyAndVisible];

    return YES;

}

- (void)createProgressView
{
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 350.0f, 320.0f, 70.0f)];
    [self.window addSubview:self.progressView];
}

#pragma mark - Private Methods
- (void)customization
{
    // UIStatusBar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    // UINavigationBar
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];

    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBar"] forBarMetrics:UIBarMetricsDefault];
    
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationLogo"]];
    self.searchNavigationController.visibleViewController.navigationItem.titleView = logoView;
    
}


#pragma mark - MBProgressHUD Methods
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

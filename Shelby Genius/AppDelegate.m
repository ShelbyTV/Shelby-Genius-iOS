//
//  AppDelegate.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "AppDelegate.h"

// Frameworks
#import <AVFoundation/AVFoundation.h>
#import <Crashlytics/Crashlytics.h>

// View Controllers
#import "SearchViewController.h"
#import "GeniusOnboardingViewController.h"
#import "VideoPlayerViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) UIView *progressView;
@property (assign, nonatomic) NSTimeInterval videoPlaybackTimeInterval;

- (void)analytics;
- (void)customization;
- (void)createProgressView;

@end

@implementation AppDelegate
@synthesize window;
@synthesize rootNavigationController;
@synthesize progressHUD = _progressHUD;
@synthesize progressView = _progressView;
@synthesize videoPlayerViewController = _videoPlayerViewController;
@synthesize videoPlaybackTimeInterval = _videoPlaybackTimeInterval;

#pragma mark - UIApplicationDelegate Methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Initialize UIWindow's rootViewController
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Check if app launched before
    BOOL previouslyLaunched = [[NSUserDefaults standardUserDefaults] boolForKey:kPreviouslyLaunched];
    
    if ( previouslyLaunched ) {
    
        SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController_iPhone" bundle:nil];
        self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
        self.window.rootViewController = rootNavigationController;
        
    } else {
        
        GeniusOnboardingViewController *geniusOnboardingViewController = [[GeniusOnboardingViewController alloc] initWithNibName:@"GeniusOnboardingViewController" bundle:nil];
        self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:geniusOnboardingViewController];
        self.window.rootViewController = rootNavigationController;
        
    }
    
    
    // Add analytics
    [self analytics];
    
    // Appearance Proxies and General Customization
    [self customization];
    
    [self.window makeKeyAndVisible];

    return YES;

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ( self.videoPlayerViewController ) {
     
        self.videoPlayerViewController.moviePlayer.initialPlaybackTime = self.videoPlaybackTimeInterval;
        [self.videoPlayerViewController.moviePlayer play];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ( self.videoPlayerViewController ) self.videoPlaybackTimeInterval = self.videoPlayerViewController.moviePlayer.currentPlaybackTime;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
    // Reset RollID (just to be on the safe side)
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRollID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)createProgressView
{
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 350.0f, 320.0f, 70.0f)];
    [self.window addSubview:self.progressView];
}

#pragma mark - Private Methods
- (void)analytics
{
    [Crashlytics startWithAPIKey:@"84a79b7ee6f2eca13877cd17b9b9a290790f99aa"];
}

- (void)customization
{
    // UIStatusBar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    // UINavigationBar
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];

    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBar"] forBarMetrics:UIBarMetricsDefault];
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationLogo"]];
    self.rootNavigationController.visibleViewController.navigationItem.titleView = logoView;
    
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

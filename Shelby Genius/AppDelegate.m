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
#import "VideoPlayerViewController.h"
#import "DetailViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@property (strong, nonatomic) UIView *progressView;
@property (assign, nonatomic) NSTimeInterval videoPlaybackTimeInterval;

- (void)setupFlags;
- (void)analytics;
- (void)customization;
- (void)createProgressView;

@end

@implementation AppDelegate
@synthesize window;
@synthesize progressHUD = _progressHUD;
@synthesize progressView = _progressView;
@synthesize rootNavigationController = _rootNavigationController;
@synthesize detailNavigationController = _detailNavigationController;
@synthesize storedQuery = _storedQuery;
@synthesize storedQueryArray = _storedQueryArray;
@synthesize numberOfResultsStoredQueryReturned = _numberOfResultsStoredQueryReturned;
@synthesize developerModeEnabled = _developerModeEnabled;
@synthesize experimentalModeEnabled = _experimentalModeEnabled;
@synthesize videoPlayerViewController = _videoPlayerViewController;
@synthesize videoPlaybackTimeInterval = _videoPlaybackTimeInterval;

#pragma mark - UIApplicationDelegate Methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // Initialize UIWindow's rootViewController
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Initialize Development Flags
    [self setupFlags];
    
    // Initialize analytics
    [self analytics];

    // Check if app/onboarding was previously launched before
    
//    if ( kDeviceIsIPad ) {
//        
//        // Initialize rootSplitViewController
//        self.rootSplitViewController = [[UISplitViewController alloc] init];
//        self.rootSplitViewController.delegate = self;
//        
//        // Left side of rootSplitViewController
//        SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
//        self.rootNavigationController = [[RootNavigationController alloc] initWithRootViewController:searchViewController];
//        
//        // Right side of rootSplitViewController
//        DetailViewController *detailViewController = [[DetailViewController alloc] init];
//        self.detailNavigationController = [[DetailNavigationController alloc] initWithRootViewController:detailViewController];
//
//        // Set rootSplitViewController as window's rootViewController
//        [self.rootSplitViewController setViewControllers:[NSArray arrayWithObjects:self.rootNavigationController, self.detailNavigationController, nil]];
//        self.window.rootViewController = self.rootSplitViewController;
//        
//        
//    } else {
    
        // Set searchViewController as window's rootViewController
        SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
        self.rootNavigationController = [[RootNavigationController alloc] initWithRootViewController:searchViewController];
        self.window.rootViewController = self.rootNavigationController;
//    }
    
    // Appearance Proxies and General Customization
    [self customization];
    
    // Make main window visible
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
    // In case a HUD exists, remove it when app is backgrounded
    [self removeHUD];
    
    // If a movie is playing, get current playback interval
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
//    if ( kDeviceIsIPad ) {
//
//        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 600.0f, 320.0f, 70.0f)];
//        UIView *searchView = [[[self.rootSplitViewController.viewControllers objectAtIndex:0] visibleViewController] view];
//        [searchView addSubview:self.progressView];
//        
//    } else {

        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 350.0f, 320.0f, 70.0f)];
        [self.window addSubview:self.progressView];

//    }
    
}

#pragma mark - Private Methods
- (void)setupFlags
{
    self.developerModeEnabled = YES;
    self.experimentalModeEnabled = NO;
}

- (void)analytics
{
    [Crashlytics startWithAPIKey:@"84a79b7ee6f2eca13877cd17b9b9a290790f99aa"];
    [KISSMetricsAPI sharedAPIWithKey:@"9b8c2d291a85a66412fc8c0085125194646fd7a6"];
}

- (void)customization
{
    // UIStatusBar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    // UINavigationBar
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIFont fontWithName:@"Ubuntu-Bold" size:20.0f], UITextAttributeFont, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:titleTextAttributes];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationBar"] forBarMetrics:UIBarMetricsDefault];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationLogo"]];
    self.rootNavigationController.visibleViewController.navigationItem.titleView = logoView;
    
    // UITableView
    [[UITableView appearance] setSeparatorColor:[UIColor colorWithRed:173.0f/255.0f green:173.0f/255.0f blue:173.0f/255.0f alpha:1.0f]];
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
    
    if ( kDeviceIsIPad ) {
        
        UIView *searchView = [[[[[[[[self.rootSplitViewController.viewControllers objectAtIndex:0] view] subviews] objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:0];
        [MBProgressHUD hideAllHUDsForView:searchView animated:YES];
        [self.progressView removeFromSuperview];
    } else {
    
        [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
        [self.progressView removeFromSuperview];
        
    }
    
}


@end

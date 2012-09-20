//
//  AppDelegate.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "RootNavigationController.h"
#import "DetailNavigationController.h"
#import "MBProgressHUD.h"
#import "MGSplitViewController.h"

@class VideoPlayerViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,  UISplitViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

// Navigation Variables
@property (strong, nonatomic) RootNavigationController *rootNavigationController;
@property (strong, nonatomic) MGSplitViewController *rootSplitViewController;
@property (strong, nonatomic) DetailNavigationController *detailNavigationController;
@property (assign, nonatomic) BOOL hideRootViewController;

// Session Persistence Variables
@property (copy, nonatomic) NSString *storedQuery;
@property (strong, nonatomic) NSMutableArray *storedQueryArray;
@property (assign, nonatomic) NSUInteger numberOfResultsStoredQueryReturned;
@property (strong ,nonatomic) VideoPlayerViewController *videoPlayerViewController;

// Notificaiton Variables
@property (strong, nonatomic) MBProgressHUD *progressHUD;

// Development Variables
@property (assign, nonatomic) BOOL developerModeEnabled; // YES while app is in Development
@property (assign, nonatomic) BOOL experimentalModeEnabled; // Experimental Feautres

- (void)addHUDWithMessage:(NSString*)message;
- (void)removeHUD;

@end
//
//  AppDelegate.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "RootNavigationController.h"
#import "MBProgressHUD.h"

@class VideoPlayerViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RootNavigationController *rootNavigationController;
@property (strong, nonatomic) UISplitViewController *rootSplitViewController;
@property (strong, nonatomic) RootNavigationController *detailNavigationController;
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (strong ,nonatomic) VideoPlayerViewController *videoPlayerViewController;

- (void)addHUDWithMessage:(NSString*)message;
- (void)removeHUD;

@end
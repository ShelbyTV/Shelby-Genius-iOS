//
//  AppDelegate.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (strong, nonatomic) ViewController *viewController;

- (void)addHUDWithMessage:(NSString*)message;
- (void)removeHUD;

@end
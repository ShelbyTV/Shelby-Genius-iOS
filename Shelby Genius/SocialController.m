//
//  SocialController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/22/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "SocialController.h"

// Frameworks
#import <MessageUI/MessageUI.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@implementation SocialController

+ (void)sendEmailForVideo:(NSArray *)video inViewController:(UIViewController *)viewController
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] initWithRootViewController:viewController];
    
}

+ (void)postToTwitterForVideo:(NSArray *)array inViewController:(UIViewController *)viewController
{
    
}

+ (void)postToFacebookForVideo:(NSArray *)array inViewController:(UIViewController *)viewController
{
    
}

@end
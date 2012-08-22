//
//  SocialController.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/22/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

@interface SocialController : NSObject

+ (void)sendEmailForVideo:(NSArray*)video inViewController:(UIViewController*)viewController;
+ (void)postToTwitterForVideo:(NSArray*)video inViewController:(UIViewController*)viewController;
+ (void)postToFacebookForVideo:(NSArray*)video inViewController:(UIViewController*)viewController;

+ (SocialController*)sharedInstance;

@end
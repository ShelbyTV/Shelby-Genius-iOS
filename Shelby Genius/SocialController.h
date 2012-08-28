//
//  SocialController.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/22/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

@class GeniusRollViewController;

@interface SocialController : NSObject

+ (void)sendEmailForVideo:(NSArray*)video inViewController:(GeniusRollViewController*)viewController;
+ (void)postToTwitterForVideo:(NSArray*)video inViewController:(GeniusRollViewController*)viewController;
+ (void)postToFacebookForVideo:(NSArray*)video inViewController:(GeniusRollViewController*)viewController;

+ (SocialController*)sharedInstance;

@end
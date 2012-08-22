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

// External Libraries
#import "AsynchronousFreeloader.h"

@implementation SocialController

+ (void)sendEmailForVideo:(NSArray *)video inViewController:(UIViewController *)viewController
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] initWithRootViewController:viewController];
    
    // Attachment
    NSString *thumnbnailURL = [video valueForKey:@"thumbnail_url"];
    UIImageView *temporaryImageView = [[UIImageView alloc] init];
    [AsynchronousFreeloader loadImageFromLink:thumnbnailURL forImageView:temporaryImageView withPlaceholderView:nil];
    NSData *imageData = UIImagePNGRepresentation(temporaryImageView.image);
    [mailViewController addAttachmentData:imageData mimeType:@"image/png" fileName:@"ShelbyTV-Video-Image"];
    
    // Subject
    NSString *videoTitle = [video valueForKey:@"title"];
    [mailViewController setSubject:[NSString stringWithFormat:@"%@ - discovered via Shelby Genius", videoTitle]];
    
    // Body
    NSString *providerName = [videoTitle valueForKey:@"provider_name"];
    NSString *providerID = [videoTitle valueForKey:@"provider_id"];
    NSString *videoURL = [NSString stringWithFormat:@"http://shelby.tv/video/%@/%@", providerName, providerID];
    NSString *message = [NSString stringWithFormat:@"I thought you might like this video: %@", videoURL];
    [mailViewController setMessageBody:message isHTML:YES];
    
    // Present mailViewController
    [viewController presentModalViewController:mailViewController animated:YES];
}

+ (void)postToTwitterForVideo:(NSArray *)array inViewController:(UIViewController *)viewController
{
    
}

+ (void)postToFacebookForVideo:(NSArray *)array inViewController:(UIViewController *)viewController
{
    
}

@end
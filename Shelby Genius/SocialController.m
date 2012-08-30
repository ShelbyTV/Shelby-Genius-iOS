//
//  SocialController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/22/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "SocialController.h"

// View Controllers
#import "GeniusRollViewController.h"

// Frameworks
#import <MessageUI/MessageUI.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface SocialController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIViewController *viewController;

@end

@implementation SocialController
@synthesize viewController = _viewController;

static SocialController *sharedInstance = nil;

#pragma mark - Singleton Methods
+ (SocialController*)sharedInstance
{
    if ( nil == sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - Sharing Methods
+ (void)sendEmailForVideo:(NSArray *)videoFrame inViewController:(GeniusRollViewController *)viewController
{
    
    [[Panhandler sharedInstance] recordEvent];
    
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:viewController.query, KISSQuery, [[videoFrame valueForKey:@"video" ] valueForKey:@"title"], KISSVideoTitle, nil];
    [[KISSMetricsAPI sharedAPI] recordEvent:KISSShareEmailPhone withProperties:metrics];
    
    [[SocialController sharedInstance] setViewController:viewController];
    
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = [SocialController sharedInstance];
    
    // Attachment
//    NSString *thumnbnailURL = [video valueForKey:@"thumbnail_url"];
//    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumnbnailURL]];
//    [mailViewController addAttachmentData:imageData mimeType:@"image/png" fileName:@"ShelbyTV-Video-Image"];
    
    // Subject
    NSString *videoTitle = [[videoFrame valueForKey:@"video"] valueForKey:@"title"];
    [mailViewController setSubject:[NSString stringWithFormat:@"%@ - via Shelby Genius", videoTitle]];
    
    // Body
    NSString *providerName = [[videoFrame valueForKey:@"video"] valueForKey:@"provider_name"];
    NSString *providerID = [[videoFrame valueForKey:@"video"] valueForKey:@"provider_id"];
    NSString *rollID = [videoFrame  valueForKey:@"roll_id"];
    NSString *frameID = [videoFrame valueForKey:@"id"];
    NSString *videoURL = [NSString stringWithFormat:@"http://shelby.tv/video/%@/%@?roll_id=%@&frame_id=%@", providerName, providerID, rollID, frameID];
    NSString *message = [NSString stringWithFormat:@"I thought you might like this video: <strong><a href=\"%@\">%@</a></strong>.<br/><br/><em>via Shelby Genius - <a href=\"http://shl.by/ios-genius-app\">grab the app!</a></em>", videoURL, videoURL];
    [mailViewController setMessageBody:message isHTML:YES];
    
    // Present mailViewController
    [viewController presentViewController:mailViewController animated:YES completion:nil];
}

+ (void)postToTwitterForVideo:(NSArray *)videoFrame inViewController:(GeniusRollViewController *)viewController
{
    
    [[Panhandler sharedInstance] recordEvent];
    
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:viewController.query, KISSQuery, [[videoFrame valueForKey:@"video" ] valueForKey:@"title"], KISSVideoTitle, nil];
    [[KISSMetricsAPI sharedAPI] recordEvent:KISSShareTwitterPhone withProperties:metrics];
    
    // Title
    NSString *videoTitle = [[videoFrame valueForKey:@"video"] valueForKey:@"title"];
    
    // URL
    NSString *providerName = [[videoFrame valueForKey:@"video"] valueForKey:@"provider_name"];
    NSString *providerID = [[videoFrame valueForKey:@"video"] valueForKey:@"provider_id"];
    NSString *rollID = [videoFrame valueForKey:@"roll_id"];
    NSString *frameID = [videoFrame valueForKey:@"id"];
    NSString *videoURL = [NSString stringWithFormat:@"http://shelby.tv/video/%@/%@?roll_id=%@&frame_id=%@", providerName, providerID, rollID, frameID];

    if ([TWTweetComposeViewController canSendTweet]) {
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ - %@ /via @Shelby", videoTitle, videoURL]];
        [tweetSheet removeAllImages];
        [viewController presentViewController:tweetSheet animated:YES completion:nil];
    }
    
}

+ (void)postToFacebookForVideo:(NSArray *)video inViewController:(GeniusRollViewController *)viewController
{
    
    [[Panhandler sharedInstance] recordEvent];
}

#pragma mark - MFMailComposeViewController
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.viewController dismissModalViewControllerAnimated:YES];
}

@end
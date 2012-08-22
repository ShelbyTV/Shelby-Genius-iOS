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
+ (void)sendEmailForVideo:(NSArray *)video inViewController:(UIViewController *)viewController
{
    
    [[SocialController sharedInstance] setViewController:viewController];
    
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = [SocialController sharedInstance];
    
    // Attachment
    NSString *thumnbnailURL = [video valueForKey:@"thumbnail_url"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumnbnailURL]];
    [mailViewController addAttachmentData:imageData mimeType:@"image/png" fileName:@"ShelbyTV-Video-Image"];
    
    // Subject
    NSString *videoTitle = [video valueForKey:@"title"];
    [mailViewController setSubject:[NSString stringWithFormat:@"%@ - discovered via Shelby Genius", videoTitle]];
    
    // Body
    NSString *providerName = [video valueForKey:@"provider_name"];
    NSString *providerID = [video valueForKey:@"provider_id"];
    NSString *videoURL = [NSString stringWithFormat:@"http://shelby.tv/video/%@/%@", providerName, providerID];
    NSString *message = [NSString stringWithFormat:@"I thought you might like this video: <strong><a href=\"%@\">%@</a></strong>.<br/><br/> This video was sent via the <strong>Shelby Genius iPhone app - <a href=\"http://www.shelby.tv\">grab it here!</a></strong>", videoURL, videoURL];
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

#pragma mark - MFMailComposeViewController
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.viewController dismissModalViewControllerAnimated:YES];
}

@end
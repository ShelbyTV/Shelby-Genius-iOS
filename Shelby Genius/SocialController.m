//
//  SocialController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/22/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "SocialController.h"

// Models
#import "AppDelegate.h"

// View Controllers
#import "GeniusRollViewController.h"

// Frameworks
#import <MessageUI/MessageUI.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
/// Social Framework in .pch file, since it's OS specific.

@interface SocialController ()  <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) GeniusRollViewController *geniusRollViewController;
@property (strong, nonatomic) NSArray *videoFrame;
@property (assign, nonatomic) SocialChannel socialChannel;
@property (strong, nonatomic) NSMutableData *responseData;
@property (copy, nonatomic) NSString *awesomeURL;

- (void)sendEmail;
- (void)postToTwitter;
- (void)postToFacebook;
- (NSString*)encodeToPercentEscapedString:(NSString*)string;
- (void)asynchronousConnectionFinished;

@end

@implementation SocialController
@synthesize videoFrame = _videoFrame;
@synthesize socialChannel = _socialChannel;
@synthesize geniusRollViewController = _geniusRollViewController;
@synthesize responseData = _responseData;
@synthesize awesomeURL = _awesomeURL;

#pragma mark - Singleton methods
static SocialController *sharedInstance = nil;

+ (SocialController*)sharedInstance
{
    if (sharedInstance == nil) {
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


#pragma mark - Public Methods
- (void)shareVideo:(NSArray*)videoFrame toChannel:(SocialChannel)socialChannel inViewController:(GeniusRollViewController*)geniusRollViewController
{

    // Add 'Sharing Video' HUD
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.appDelegate addHUDWithMessage:@"Sharing Video"];
    
    // Set References
    self.videoFrame = videoFrame;
    self.socialChannel = socialChannel;
    self.geniusRollViewController = geniusRollViewController;
    
    // Extract Video Data
    NSString *videoTitle = [[self.videoFrame valueForKey:@"video"] valueForKey:@"title"];
    videoTitle = [videoTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *providerName = [[self.videoFrame valueForKey:@"video"] valueForKey:@"provider_name"];
    NSString *providerID = [[self.videoFrame valueForKey:@"video"] valueForKey:@"provider_id"];
    NSString *rollID = [self.videoFrame  valueForKey:@"roll_id"];
    NSString *frameID = [self.videoFrame valueForKey:@"id"];
    NSString *videoURL = [NSString stringWithFormat:@"http://shelby.tv/video/%@/%@?roll_id=%@&frame_id=%@", providerName, providerID, rollID, frameID];
    
    NSLog(@"%@", frameID);
    
    switch (self.socialChannel) {
            
        case SocialShare_None:
            break;
            
        case SocialShare_Email:{
            
            NSString *requestString = [NSString stringWithFormat:AWESMLinkCreatorEmail, videoURL, videoTitle];
            requestString = [self encodeToPercentEscapedString:requestString];
            requestString = [NSString stringWithFormat:AWESMEmail, requestString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
            [request setHTTPMethod:@"GET"];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 if( data.length > 0 && error == nil ) {
                     
                     self.responseData = [NSMutableData dataWithData:data];
                     [self asynchronousConnectionFinished];
                     
                 }
             }];
            
        } break;
            
        case SocialShare_Twitter:{
            
            NSString *requestString = [NSString stringWithFormat:AWESMLinkCreatorTwitter, videoURL, videoTitle];
            requestString = [self encodeToPercentEscapedString:requestString];
            requestString = [NSString stringWithFormat:AWESMTwitter, requestString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
            [request setHTTPMethod:@"GET"];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
            {
                if( data.length > 0 && error == nil ) {
               
                    self.responseData = [NSMutableData dataWithData:data];
                    [self asynchronousConnectionFinished];
     
                }
            }];
            
        } break;
            
        case SocialShare_Facebook:{
            
            NSString *requestString = [NSString stringWithFormat:AWESMLinkCreatorFacebook, videoURL, videoTitle];
            requestString = [self encodeToPercentEscapedString:requestString];
            requestString = [NSString stringWithFormat:AWESMFacebook, requestString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
            [request setHTTPMethod:@"GET"];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 if( data.length > 0 && error == nil ) {
                     
                     self.responseData = [NSMutableData dataWithData:data];
                     [self asynchronousConnectionFinished];
                     
                 }
             }];
            
        } break;
            
        default:
            break;
    }
    
}

#pragma mark - Private Methods
- (void)sendEmail
{
    // Analytics
    [[Panhandler sharedInstance] recordEvent];
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.geniusRollViewController.query, KISSQuery, [[self.videoFrame valueForKey:@"video" ] valueForKey:@"title"], KISSVideoTitle, nil];
    [[KISSMetricsController sharedInstance] sendActionToKISSMetrics:KISSMetricsStatistic_Share andMetrics:metrics];
    
    
    // Mail Setup
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    
    // Subject
    NSString *videoTitle = [[self.videoFrame valueForKey:@"video"] valueForKey:@"title"];
    [mailViewController setSubject:[NSString stringWithFormat:@"%@ - via Shelby Genius", videoTitle]];
    
    // Body
    NSString *message = [NSString stringWithFormat:@"I thought you might like this video: <strong><a href=\"%@\">%@</a></strong>.<br/><br/><em>via Shelby Genius - <a href=\"http://shl.by/ios-genius-app\">grab the app!</a></em>", self.awesomeURL, videoTitle];
    [mailViewController setMessageBody:message isHTML:YES];
    
    // Present mailViewController
    [self.geniusRollViewController presentViewController:mailViewController animated:YES completion:nil];
}

- (void)postToTwitter
{
    // Analytics
    [[Panhandler sharedInstance] recordEvent];
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.geniusRollViewController.query, KISSQuery, [[self.videoFrame valueForKey:@"video" ] valueForKey:@"title"], KISSVideoTitle, nil];
    [[KISSMetricsController sharedInstance] sendActionToKISSMetrics:KISSMetricsStatistic_Share andMetrics:metrics];
    
    // Extract Video Data
    NSString *videoTitle = [[self.videoFrame valueForKey:@"video"] valueForKey:@"title"];

    if ( kSystemVersion6 ) { 
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            
            SLComposeViewController *socialController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            SLComposeViewControllerCompletionHandler completionHandler = ^(SLComposeViewControllerResult result) {
                [socialController dismissViewControllerAnimated:YES completion:Nil];
            };
            socialController.completionHandler = completionHandler;
            [socialController setInitialText:[NSString stringWithFormat:@"%@ - %@ /via @Shelby", videoTitle, self.awesomeURL]];
            
            [self.geniusRollViewController presentViewController:socialController animated:YES completion:nil];
            
        }

        
    } else { 
        
        if ([TWTweetComposeViewController canSendTweet]) {
            
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
            [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ - %@ /via @Shelby", videoTitle, self.awesomeURL]];
            [tweetSheet removeAllImages];
            
            [self.geniusRollViewController presentViewController:tweetSheet animated:YES completion:nil];
            
        }
        
    }
    
}

- (void)postToFacebook
{
    
    if ( kSystemVersion6 ) {
    
        // Analytics
        [[Panhandler sharedInstance] recordEvent];
        NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.geniusRollViewController.query, KISSQuery, [[self.videoFrame valueForKey:@"video" ] valueForKey:@"title"], KISSVideoTitle, nil];
        [[KISSMetricsController sharedInstance] sendActionToKISSMetrics:KISSMetricsStatistic_Share andMetrics:metrics];
     
        // Extract Video Data
        NSString *videoTitle = [[self.videoFrame valueForKey:@"video"] valueForKey:@"title"];
        NSString *videoThumbnail = [[self.videoFrame valueForKey:@"video"] valueForKey:@"thumbnail_url"];
        NSData *thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoThumbnail]];
        UIImage *thumbnail = [UIImage imageWithData:thumbnailData];
        
        // Facebook Post
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            
            SLComposeViewController *socialController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            SLComposeViewControllerCompletionHandler completionHandler = ^(SLComposeViewControllerResult result) {
                [socialController dismissViewControllerAnimated:YES completion:Nil];
            };
            socialController.completionHandler = completionHandler;
            [socialController setInitialText:[NSString stringWithFormat:@"%@ - via Shelby Genius", videoTitle]];
            [socialController addURL:[NSURL URLWithString:self.awesomeURL]];
            [socialController addImage:thumbnail];
            
            [self.geniusRollViewController presentViewController:socialController animated:YES completion:nil];
            
        }
        
    }
    
}


- (NSString*)encodeToPercentEscapedString:(NSString*)string
{
    string = ((__bridge NSString *)(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                      (CFStringRef) string,
                                                      NULL,
                                                      (CFStringRef) @"&",
                                                      kCFStringEncodingUTF8)));
    
    return string;
}


#pragma mark - Asynchronous Connection Finished
- (void)asynchronousConnectionFinished
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        // Remove 'Sharing Video' HUD
        [self.appDelegate removeHUD];
        
        // Parse JSON Data
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
        
        // Extract awe.sm URL
        self.awesomeURL = [responseDictionary valueForKey:@"awesm_url"];
        NSLog(@"Awesome URL: %@", self.awesomeURL);
        
        switch (self.socialChannel) {
                
            case SocialShare_None:
                break;
                
            case SocialShare_Email:
                [self sendEmail];
                break;
                
            case SocialShare_Twitter:
                [self postToTwitter];
                break;
                
            case SocialShare_Facebook:
                [self postToFacebook];
                break;
                
            default:
                break;
        }

        
        
    });
    
}

#pragma mark - MFMailComposeViewController
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.geniusRollViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
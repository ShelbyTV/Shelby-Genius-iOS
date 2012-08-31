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

// External Libraries
#import "Reachability.h"

// Frameworks
#import <MessageUI/MessageUI.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface SocialController () <MFMailComposeViewControllerDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) GeniusRollViewController *geniusRollViewController;
@property (strong, nonatomic) NSArray *videoFrame;
@property (assign, nonatomic) SocialChannel socialChannel;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *responseData;
@property (copy, nonatomic) NSString *awesomeURL;

- (void)sendEmail;
- (void)postToTwitter;
- (void)postToFacebook;
- (NSString*)encodeToPercentEscapedString:(NSString*)string;

@end

@implementation SocialController
@synthesize videoFrame = _videoFrame;
@synthesize socialChannel = _socialChannel;
@synthesize geniusRollViewController = _geniusRollViewController;
@synthesize connection = _connection;
@synthesize responseData = _responseData;
@synthesize awesomeURL = _awesomeURL;

#pragma mark - Public
- (void)shareVideo:(NSArray*)videoFrame toChannel:(SocialChannel)socialChannel inViewController:(GeniusRollViewController*)geniusRollViewController
{
    // Set References
    self.videoFrame = videoFrame;
    self.socialChannel = socialChannel;
    self.geniusRollViewController = geniusRollViewController;
 
    
    // Initialize Reachability
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    [reach startNotifier];
    
    // If internet connection is AVAILABLE, execute this block of code.
    reach.reachableBlock = ^(Reachability *reach){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Internet Connection Available");
            
            NSString *videoTitle = [[self.videoFrame valueForKey:@"video"] valueForKey:@"title"];
            videoTitle = [videoTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *providerName = [[self.videoFrame valueForKey:@"video"] valueForKey:@"provider_name"];
            NSString *providerID = [[self.videoFrame valueForKey:@"video"] valueForKey:@"provider_id"];
            NSString *rollID = [self.videoFrame  valueForKey:@"roll_id"];
            NSString *frameID = [self.videoFrame valueForKey:@"id"];
            NSString *videoURL = [NSString stringWithFormat:@"http://shelby.tv/video/%@/%@?roll_id=%@&frame_id=%@", providerName, providerID, rollID, frameID];
            
            switch (self.socialChannel) {
                    
                case SocialShare_Email:{
                    
                    NSString *requestString = [NSString stringWithFormat:AWESMLinkCreator, videoURL, videoTitle];
                    requestString = [self encodeToPercentEscapedString:requestString];
                    requestString = [NSString stringWithFormat:AWESMEmail, requestString];
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
                    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    
                    NSLog(@"%@", requestString);
                    
                } break;
                    
                case SocialShare_Twitter:{
                    
                    NSString *requestString = [NSString stringWithFormat:AWESMLinkCreator, videoURL, videoTitle];
                    requestString = [self encodeToPercentEscapedString:requestString];
                    requestString = [NSString stringWithFormat:AWESMTwitter, requestString];
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
                    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    
                    NSLog(@"%@", requestString);
                    
                } break;
                    
                case SocialShare_Facebook:{
                } break;
                    
                default:
                    break;
            }
            
            
        });
        
    };
    
    // If internet connection is UNAVAILABLE, execute this block of code.
    reach.unreachableBlock = ^(Reachability *reach){
        
        NSLog(@"Internet Connection Unavailable");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//            [appDelegate addHUDWithMessage:@"WiFi/3G unavailable. Check your settings."];
//            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(connectionUnavailable:) userInfo:nil repeats:NO];
            
        });
        
    };        
    
}

#pragma mark - Private Methods
- (void)sendEmail
{
    // Analytics
    [[Panhandler sharedInstance] recordEvent];
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.geniusRollViewController.query, KISSQuery, [[self.videoFrame valueForKey:@"video" ] valueForKey:@"title"], KISSVideoTitle, nil];
    [[KISSMetricsAPI sharedAPI] recordEvent:KISSSharePhone withProperties:metrics];
    
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
    [[KISSMetricsAPI sharedAPI] recordEvent:KISSSharePhone withProperties:metrics];
    
    // Title
    NSString *videoTitle = [[self.videoFrame valueForKey:@"video"] valueForKey:@"title"];

    if ([TWTweetComposeViewController canSendTweet]) {
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ - %@ /via @Shelby", videoTitle, self.awesomeURL]];
        [tweetSheet removeAllImages];
        [self.geniusRollViewController presentViewController:tweetSheet animated:YES completion:nil];
    }
    
}

- (void)postToFacebook
{
    // Analytics
    [[Panhandler sharedInstance] recordEvent];
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.geniusRollViewController.query, KISSQuery, [[self.videoFrame valueForKey:@"video" ] valueForKey:@"title"], KISSVideoTitle, nil];
    [[KISSMetricsAPI sharedAPI] recordEvent:KISSSharePhone withProperties:metrics];
    
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


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ( ![self responseData] )self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ( error ) {
        
        NSLog(@"Sharing Error");
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    // Parse JSON Data
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
    
    self.awesomeURL = [responseDictionary valueForKey:@"awesm_url"];
    
    NSLog(@"%@", self.awesomeURL);
    
    switch (self.socialChannel) {
            
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
    
}

#pragma mark - MFMailComposeViewController
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.geniusRollViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
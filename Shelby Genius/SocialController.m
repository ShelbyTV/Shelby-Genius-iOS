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

@interface SocialController ()  <MFMailComposeViewControllerDelegate, NSURLConnectionDataDelegate>

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
    
    switch (self.socialChannel) {
            
        case SocialShare_None:
            break;
            
        case SocialShare_Email:{
            
            NSString *requestString = [NSString stringWithFormat:AWESMLinkCreator, videoURL, videoTitle];
            requestString = [self encodeToPercentEscapedString:requestString];
            requestString = [NSString stringWithFormat:AWESMEmail, requestString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
            self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        } break;
            
        case SocialShare_Twitter:{
            
            NSString *requestString = [NSString stringWithFormat:AWESMLinkCreator, videoURL, videoTitle];
            requestString = [self encodeToPercentEscapedString:requestString];
            requestString = [NSString stringWithFormat:AWESMTwitter, requestString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
            self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        } break;
            
        case SocialShare_Facebook:{
            
            NSString *requestString = [NSString stringWithFormat:AWESMLinkCreator, videoURL, videoTitle];
            requestString = [self encodeToPercentEscapedString:requestString];
            requestString = [NSString stringWithFormat:AWESMFacebook, requestString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
            self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
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
    
    // Extract Video Data
    NSString *videoTitle = [[self.videoFrame valueForKey:@"video"] valueForKey:@"title"];

    // Twitter Post
    if ([TWTweetComposeViewController canSendTweet]) {
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ - %@ /via @Shelby", videoTitle, self.awesomeURL]];
        [tweetSheet removeAllImages];
        [self.geniusRollViewController presentViewController:tweetSheet animated:YES completion:nil];
    }
    
}

- (void)postToFacebook
{
    
    if ( 6 == kSystemVersion ) {
    
        // Analytics
        [[Panhandler sharedInstance] recordEvent];
        NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.geniusRollViewController.query, KISSQuery, [[self.videoFrame valueForKey:@"video" ] valueForKey:@"title"], KISSVideoTitle, nil];
        [[KISSMetricsAPI sharedAPI] recordEvent:KISSSharePhone withProperties:metrics];
     
        // Extract Video Data 
        NSString *videoTitle = [[self.videoFrame valueForKey:@"video"] valueForKey:@"title"];
        NSString *videoThumbnail = [[self.videoFrame valueForKey:@"video"] valueForKey:@"thumbnail_url"];
        NSData *thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoThumbnail]];
        UIImage *thumbnail = [UIImage imageWithData:thumbnailData];
        
        // Facebook Post
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            SLComposeViewControllerCompletionHandler facebookCompletionHandler = ^(SLComposeViewControllerResult result) {
                
                [controller dismissViewControllerAnimated:YES completion:Nil];
            };
            
            controller.completionHandler = facebookCompletionHandler;
            
            [controller setInitialText:[NSString stringWithFormat:@"%@ - via Shelby Genius", videoTitle]];
            [controller addURL:[NSURL URLWithString:self.awesomeURL]];
            [controller addImage:thumbnail];
            
            [self.geniusRollViewController presentViewController:controller animated:YES completion:nil];
            
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
        
        switch (self.socialChannel) {
                
            case SocialShare_None:
                    break;
                
            case SocialShare_Email:{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sharing Failed"
                                                                    message:@"There was a problem sharing via Email"
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"Dismiss", nil];
                [alertView show];
                
                } break;
                
            case SocialShare_Twitter:{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sharing Failed"
                                                                    message:@"There was a problem sharing to Twitter"
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"Dismiss", nil];
                [alertView show];
                
            } break;
        
            case SocialShare_Facebook:{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sharing Failed"
                                                                    message:@"There was a problem sharing to Faceabook"
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"Dismiss", nil];
                [alertView show];
                
                } break;
    
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    // Parse JSON Data
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
    
    self.awesomeURL = [responseDictionary valueForKey:@"awesm_url"];
    
    NSLog(@"%@", self.awesomeURL);
    
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
    
}

#pragma mark - MFMailComposeViewController
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.geniusRollViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
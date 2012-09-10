//
//  APIClient.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "APIClient.h"
#import "Reachability.h"
#import "AppDelegate.h"

@interface APIClient () <NSURLConnectionDataDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *responseData;
@property (assign, nonatomic) APIRequestType type;
@property (strong, nonatomic) NSString *query;

- (void)asynchronousConnectionFinished;
- (void)connectionUnavailable:(NSNotification*)notification;
- (NSMutableArray*)arrayWithLinks:(NSDictionary*)responseDictionary;
- (void)createGeniusQueryWithLinks:(NSMutableArray*)links;
- (void)getRoll:(NSString*)rollID;

@end

@implementation APIClient
@synthesize connection = _connection;
@synthesize responseData = _responseData;
@synthesize type = _type;
@synthesize query = _query;

#pragma mark - Public Methods
- (void)performRequest:(NSMutableURLRequest*)request ofType:(APIRequestType)type withQuery:(NSString*)query
{
    self.query = query;    
    self.type = type;
    
    // Initialize Reachability
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    [reach startNotifier];
    
    // If internet connection is AVAILABLE, execute this block of code.
    reach.reachableBlock = ^(Reachability *reach){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Internet Connection Available");
            
            // Initialize Request
//            self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 if( data.length > 0 && error == nil ) {
                     
                     self.responseData = [NSMutableData dataWithData:data];
                     [self asynchronousConnectionFinished];
                     
                 }
             }];
            
            
            // Show statusBar activity indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            
        });
        
    };
    
    // If internet connection is UNAVAILABLE, execute this block of code.
    reach.unreachableBlock = ^(Reachability *reach){
        
        NSLog(@"Internet Connection Unavailable");
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate addHUDWithMessage:@"WiFi/3G unavailable. Check your settings."];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(connectionUnavailable:) userInfo:nil repeats:NO];
            
        });
        
    };


}

#pragma mark - Asynchronous Connection Finished
- (void)asynchronousConnectionFinished
{
    
    dispatch_async(dispatch_get_main_queue(), ^{

        // Hide statusBar activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        switch (self.type) {
                
            case APIRequestType_GetQuery:{
                
                NSLog(@"YouTube Data Received");
                
                // Parse JSON Data
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
                
                // Clear responseData
                [self.responseData setLength:0];
                
                // Extract YouTube Links from responseDictionary
                NSMutableArray *links = [self arrayWithLinks:responseDictionary];
                
                // Create Genius Query with YouTube Links
                [self createGeniusQueryWithLinks:links];
                
                
            } break;
                
            case APIRequestType_PostGenius:{
                
                NSLog(@"Seed Videos Sent");
                
                // Parse JSON Data
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
                
                // Clear responseData
                [self.responseData setLength:0];
                
                // Create RollFrames request with returend Genius roll id
                [self getRoll:[[responseDictionary valueForKey:@"result"] valueForKey:@"id"]];
                
            } break;
                
            case APIRequestType_GetRollFrames:{
                
                NSLog(@"Genius Frames Returned");
                
                // Parse JSON Data
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
                
                // Clear responseData
                [self.responseData setLength:0];
                
                // Post Notification
                NSString *querySpecificObserver = [NSString stringWithFormat:@"%@_%@", kRollFramesObserver, self.query];
                [[NSNotificationCenter defaultCenter] postNotificationName:querySpecificObserver
                                                                    object:nil
                                                                  userInfo:responseDictionary];
                
                
            } break;
                
            default:
                break;
        }
        
        
    });
    
}


#pragma mark - Private Methods
- (void)connectionUnavailable:(NSNotification*)notification
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.rootNavigationController popToRootViewControllerAnimated:YES];
}

- (NSMutableArray*)arrayWithLinks:(NSDictionary*)responseDictionary
{
    NSMutableArray *links = [NSMutableArray array];
    NSArray *entryArray = [[responseDictionary valueForKey:@"feed"] valueForKey:@"entry"];
    
    for ( NSUInteger i=0; i<[entryArray count]; i++) {
        
        // Get YouTube URL
        NSString *source = [[[entryArray objectAtIndex:i] valueForKey:@"content"] valueForKey:@"src"];
        source = [source stringByReplacingOccurrencesOfString:@"?version=3&f=videos&app=youtube_gdata" withString:@""];
        
        // If URL exists, add it to array of links
        if ( source.length ) [links addObject:source];
        
    }
    
    return links;
}
- (void)createGeniusQueryWithLinks:(NSMutableArray *)links
{
    // Create Genius Query
    NSString *linksString =  @"[";
    for ( NSUInteger i = 0; i<[links count]; i++) {
        
        if (i != [links count]-1) {
            
            linksString = [NSString stringWithFormat:@"%@\"%@\",", linksString, [links objectAtIndex:i]];
            
        } else {
            
            linksString = [NSString stringWithFormat:@"%@\"%@\"]", linksString, [links objectAtIndex:i]];

        }
        
    }
    
    // Create JSON object from linksString
    NSData *linksData = [linksString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *linksStringJSON = [NSJSONSerialization JSONObjectWithData:linksData options:0 error:nil];
    
    // Perform Genius Request
    NSString *requestString = [NSString stringWithFormat:kPostGenius, self.query, linksStringJSON];
    requestString = [requestString stringByReplacingOccurrencesOfString:@"(" withString:@"["];
    requestString = [requestString stringByReplacingOccurrencesOfString:@")" withString:@"]"];
    NSURL *requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [self performRequest:request ofType:APIRequestType_PostGenius withQuery:self.query];

}

- (void)getRoll:(NSString *)rollID
{
    [[NSUserDefaults standardUserDefaults] setObject:rollID forKey:kRollID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *requestString = [NSString stringWithFormat:kGetRollFrames, rollID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [self performRequest:request ofType:APIRequestType_GetRollFrames withQuery:self.query];
}

@end
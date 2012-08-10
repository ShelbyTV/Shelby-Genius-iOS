//
//  APIClient.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "APIClient.h"

@interface APIClient () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *responseData;
@property (assign, nonatomic) APIRequestType type;
@property (strong, nonatomic) NSString *query;

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
    
    switch (type) {
        
        case APIRequestType_GetQuery:{
            self.query = query;
        } break;
            
        case APIRequestType_PostGenius:{
            // Do nothing
        } break;
            
        case APIRequestType_GetRollFrames:{
            // Do nothing
        } break;
            
        default:
            break;
    }
    
    self.type = type;
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - Private Methods
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
    [self performRequest:request ofType:APIRequestType_PostGenius withQuery:nil];

}

- (void)getRoll:(NSString *)rollID
{
    [[NSUserDefaults standardUserDefaults] setObject:rollID forKey:kRollID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *requestString = [NSString stringWithFormat:kGetRollFrames, rollID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [self performRequest:request ofType:APIRequestType_GetRollFrames withQuery:nil];
}


#pragma mark - NSURLConnectionDataDelegate Methods
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
    switch (self.type) {
        case APIRequestType_GetQuery:
            NSLog(@"Error with Query");
            break;
            case APIRequestType_PostGenius:
            NSLog(@"Error with Genius");
            break;
        case APIRequestType_GetRollFrames:
            NSLog(@"Error with RollFrames");
            break;
        default:
            break;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    switch (self.type) {
            
        case APIRequestType_GetQuery:{
            
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
            
            // Parse JSON Data
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];

            // Clear responseData
            [self.responseData setLength:0];
            
            // Create RollFrames request with returend Genius roll id
            [self getRoll:[[responseDictionary valueForKey:@"result"] valueForKey:@"id"]];
            
        } break;
            
        case APIRequestType_GetRollFrames:{
            
            // Parse JSON Data
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
            
            // Clear responseData
            [self.responseData setLength:0];
 
            // Post Notification
            [[NSNotificationCenter defaultCenter] postNotificationName:kRollFramesObserver
                                                                object:nil
                                                              userInfo:responseDictionary];
            
            
        } break;
            
        default:
            break;
    }
    
}

@end
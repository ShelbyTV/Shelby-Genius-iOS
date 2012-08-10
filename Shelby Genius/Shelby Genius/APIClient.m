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
- (NSString *)JSONString:(NSString *)aString;

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
        
        case APIRequestType_Query:{
            self.query = query;
        } break;
            
        case APIRequestType_Genius:{
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
    NSString *requestString = [NSString stringWithFormat:kGeniusAddress, self.query, linksStringJSON];
    NSURL *requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [self performRequest:request ofType:APIRequestType_Genius withQuery:nil];
    
    
}

- (NSString *)JSONString:(NSString *)aString
{
    NSMutableString *s = [NSMutableString stringWithString:aString];
	[s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	return [NSString stringWithString:s];
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
        case APIRequestType_Query:
            NSLog(@"Error with Search Query");
            break;
            case APIRequestType_Genius:
            NSLog(@"Error with Genius Query");
            break;
        default:
            break;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    switch (self.type) {
            
        case APIRequestType_Query:{
            
            // Parse JSON Data from YouTube
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];

            // Nil the responseData
            [self.responseData setLength:0];
            
            // Extract YouTube Links from responseDictionary
            NSMutableArray *links = [self arrayWithLinks:responseDictionary];
            
            // Create Genius Query with YouTube Links
            [self createGeniusQueryWithLinks:links];
            
            
        } break;
        
        case APIRequestType_Genius:{
            
            // Parse JSON Data from YouTube
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];

            NSLog(@"%@", responseDictionary);
            
        } break;
            
        default:
            break;
    }
    
}

@end

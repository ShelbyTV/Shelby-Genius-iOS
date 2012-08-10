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

@end

@implementation APIClient
@synthesize connection = _connection;
@synthesize responseData = _responseData;
@synthesize type = _type;
@synthesize query = _query;

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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [[NSMutableData alloc] init];
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
            
            NSDictionary *responseDictionary = [NSDictionary dictionary];
            responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
            
            NSMutableArray *links = [NSMutableArray array];
            NSArray *entryArray = [[responseDictionary valueForKey:@"feed"] valueForKey:@"entry"];
            
            for ( NSUInteger i=0; i<[entryArray count]; i++) {
                
                // Get YouTube URL
                NSString *source = [[[entryArray objectAtIndex:i] valueForKey:@"content"] valueForKey:@"src"];
                
                // If URL exists, add it to array of links
                if ( source.length ) [links addObject:source];
                
            }
            
            NSLog(@"Links: %@", links);
            
            
        } break;
        
        case APIRequestType_Genius:{
            
            
        } break;
            
        default:
            break;
    }
    
}

@end

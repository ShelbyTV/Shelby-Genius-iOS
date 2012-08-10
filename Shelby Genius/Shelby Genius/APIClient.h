//
//  APIClient.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _APIRequestType
{
    
    APIRequestType_None = 0,
    APIRequestType_Query,
    APIRequestType_Genius
    
} APIRequestType;

@interface APIClient : NSObject

- (void)performRequest:(NSMutableURLRequest*)request ofType:(APIRequestType)type;

@end
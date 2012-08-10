//
//  APIClient.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIClient : NSObject

- (void)performRequest:(NSMutableURLRequest*)request ofType:(APIRequestType)type withQuery:(NSString*)query;

@end
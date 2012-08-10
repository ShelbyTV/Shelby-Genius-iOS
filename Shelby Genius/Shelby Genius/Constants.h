//
//  Constants.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

typedef enum _APIRequestType
{
    
    APIRequestType_None = 0,
    APIRequestType_Query,
    APIRequestType_Genius
    
} APIRequestType;

#define kQueryAddress   @"http://gdata.youtube.com/feeds/api/videos?alt=json&v=2&cbid=1344556171863&q=%@&max-results=50&orderby=relevance"
#define kGeniusAddress  @"http://api.gt.shelby.tv/v1/roll/genius/create?search=%@&url=%@"
//
//  Constants.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

// Structures
typedef enum _APIRequestType
{
    
    APIRequestType_None = 0,
    APIRequestType_GetQuery,
    APIRequestType_PostGenius,
    APIRequestType_GetRollFrames
    
} APIRequestType;

typedef enum _VideoProvider
{
    
    VideoProvider_None = 0,
    VideoProvider_YouTube,
    VideoProvider_Vimeo,
    VideoProvider_DailyMotion
    
} VideoProvider;

// API Routes
#define kGetQuery               @"http://gdata.youtube.com/feeds/api/videos?alt=json&v=2&cbid=1344556171863&q=%@&max-results=50&orderby=relevance"
#define kPostGenius             @"http://api.gt.shelby.tv/v1/roll/genius?search=%@&urls=%@"
#define kGetRollFrames          @"http://api.gt.shelby.tv/v1/roll/%@/frames"
#define kGetRollFramesAgain     @"http://api.gt.shelby.tv/v1/roll/%@/frames?skip=%d"

// Other Constants
#define kRollFramesObserver     @"RollFrames Observer"
#define kRollID                 @"Roll ID"

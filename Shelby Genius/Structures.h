//
//  Structures.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

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
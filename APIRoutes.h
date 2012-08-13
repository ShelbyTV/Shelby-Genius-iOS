//
//  APIRoutes.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#define kGetQuery                       @"http://gdata.youtube.com/feeds/api/videos?alt=json&v=2&cbid=1344556171863&q=%@&max-results=50&orderby=relevance"
#define kPostGenius                     @"http://api.gt.shelby.tv/v1/roll/genius?search=%@&urls=%@"
#define kGetRollFrames                  @"http://api.gt.shelby.tv/v1/roll/%@/frames"
#define kGetRollFramesAgain             @"http://api.gt.shelby.tv/v1/roll/%@/frames?skip=%d"
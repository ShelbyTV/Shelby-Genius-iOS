//
//  SocialController.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/22/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

@class GeniusRollViewController;

@interface SocialController : NSObject

- (void)shareVideo:(NSArray*)videoFrame toChannel:(SocialChannel)socialChannel inViewController:(GeniusRollViewController*)geniusRollViewController;

@end
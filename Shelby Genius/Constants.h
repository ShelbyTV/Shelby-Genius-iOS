//
//  Constants.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "Structures.h"
#import "APIRoutes.h"

/// NSUserDefaults
#define kPreviouslyLaunched                 @"Previously Launched"
#define kRollID                             @"Roll ID"  
#define kPreviousQueries                    @"Previous Queries"

/// Search Query Settings
#define kMinimumVideoCountBeforeFetch       20
#define kMaximumNumberOfQueries             30

/// Observers
#define kNoResultsReturnedObserver          @"No Results Returned Observer"
#define kRollFramesObserver                 @"Roll Frames Observer"
#define kIndexOfCurrentVideoObserver        @"Index of Current Video Observer"
#define kIndexOfCurrentVideo                @"Index of Current Video"

/// Tags
#define kAlertViewNoResultsTag              666

/// Device Constants
#define kSystemVersion6                     6 == [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] intValue]
#define kDeviceIsIPad                       [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

/// Awe.sm Links
#define AWESMLinkCreatorEmail               @"%@&utm_campaign=iphone_genius&utm_source=email&utm_medium=%@"
#define AWESMEmail                          @"http://api.awe.sm/url?v=3&key=4ea2c3fea0f4e946723d1022b14f87b02e972e12e5e65a21d0724b6426687320&tool=tM32qa&format=json&channel=email&url=%@"
#define AWESMLinkCreatorTwitter             @"%@&utm_campaign=iphone_genius&utm_source=twitter&utm_medium=%@"
#define AWESMTwitter                        @"http://api.awe.sm/url?v=3&key=4ea2c3fea0f4e946723d1022b14f87b02e972e12e5e65a21d0724b6426687320&tool=tM32qa&format=json&channel=twitter&url=%@"
#define AWESMLinkCreatorFacebook            @"%@&utm_campaign=iphone_genius&utm_source=facebook&utm_medium=%@"
#define AWESMFacebook                       @"http://api.awe.sm/url?v=3&key=4ea2c3fea0f4e946723d1022b14f87b02e972e12e5e65a21d0724b6426687320&tool=tM32qa&format=json&channel=facebook&url=%@"

/// KISSMetrics Events
// iPhone
#define KISSFirstTimeUserPhone              @"First time launch on iPhone Genius"
#define KISSRepeatUserPhone                 @"Repeat launch on iPhone Genius"
#define KISSPerformQueryPhone               @"Perform query on iPhone Genius"
#define KISSWatchVideoPhone                 @"Watch video on iPhone Genius"
#define KISSSharePhone                      @"Share on iPhone Genius"

// iPad
#define KISSFirstTimeUserPad                @"First time launch on iPad Genius"
#define KISSRepeatUserPad                   @"Repeat launch on iPad Genius"
#define KISSPerformQueryPad                 @"Perform query on iPad Genius"
#define KISSWatchVideoPad                   @"Watch video on iPad Genius"
#define KISSSharePad                        @"Share on iPad Genius"

/// KISSMetrics Properties
#define KISSQuery                           @"Search query on iPhone Genius"
#define KISSVideoTitle                      @"Video title on iPhone Genius"


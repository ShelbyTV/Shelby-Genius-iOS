//
//  Constants.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "Structures.h"
#import "APIRoutes.h"

// NSUserDefaults
#define kPreviouslyLaunched                 @"Previously Launched"
#define kRollID                             @"Roll ID"  

// Query
#define kMinimumVideoCountBeforeFetch       20
#define kMaximumNumberOfQueries             8
#define kPreviousQueries                    @"Previous Queries"

// Observer
#define kNoResultsReturnedObserver          @"No Results Returned Observer"
#define kRollFramesObserver                 @"Roll Frames Observer"
#define kIndexOfCurrentVideoObserver        @"Index of Current Video Observer"
#define kIndexOfCurrentVideo                @"Index of Current Video"

// Tags
#define kAlertViewNoResultsTag              666

// KISSMetrics Events
#define KISSFirstTimeUserPhone              @"First time launch on iPhone Genius"
#define KISSRepeatUserPhone                 @"Repeat launch on iPhone Genius"
#define KISSPerformQueryPhone               @"Perform query on iPhone Genius"
#define KISSPerformQueryAgainPhone          @"Perform query again on iPhone Genius"
#define KISSWatchVideoPhone                 @"Watch video on iPhone Genius"
#define KISSSharePhone                 @"Share on iPhone Genius"

// KISSMetrics Properties
#define KISSQuery                           @"Search query on iPhone Genius"
#define KISSVideoTitle                      @"Video title on iPhone Genius"


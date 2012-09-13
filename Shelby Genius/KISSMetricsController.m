//
//  KISSMetricsController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 9/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "KISSMetricsController.h"
#import "AppDelegate.h"

@interface KISSMetricsController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (assign, nonatomic) KISSMetricsStatistic statistic;
@property (strong, nonatomic) NSDictionary *metrics;

- (void)actionPerformedOnPad;
- (void)actionPerformedOnPhone;

@end

@implementation KISSMetricsController
@synthesize appDelegate = _appDelegate;
@synthesize statistic = _statistic;
@synthesize metrics = _metrics;

#pragma mark - Singleton methods
static KISSMetricsController *sharedInstance = nil;

+ (KISSMetricsController*)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - Public Methods
- (void)sendActionToKISSMetrics:(KISSMetricsStatistic)statistic andMetrics:(NSDictionary *)metrics
{
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ( NO == [self.appDelegate developerModeEnabled] ) {
        
        self.statistic = statistic;
        if ( metrics ) self.metrics = metrics;
        
        if ( kDeviceIsIPad ) {
            [self actionPerformedOnPad];
        } else {
            [self actionPerformedOnPhone];
        }
    
    }

}

#pragma mark - Private Methods
- (void)actionPerformedOnPad
{
    switch (self.statistic) {
        case KISSMetricsStatistic_None:
            // Do Nothing
            break;
        case KISSMetricsStatistic_FirstTimeUser:
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSFirstTimeUserPad withProperties:nil];
            break;
        case KISSMetricsStatistic_RepeatUser:
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSRepeatUserPad withProperties:nil];
            break;
        case KISSMetricsStatistic_PerformQuery:
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSPerformQueryPad withProperties:self.metrics];
            break;
        case KISSMetricsStatistic_WatchVideo:
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSWatchVideoPad withProperties:self.metrics];
            break;
        case KISSMetricsStatistic_Share:
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSSharePad withProperties:self.metrics];
            break;
        default:
            break;
    }
}

- (void)actionPerformedOnPhone
{
    switch (self.statistic) {
        case KISSMetricsStatistic_None:
            // Do Nothing
            break;
        case KISSMetricsStatistic_FirstTimeUser:
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSFirstTimeUserPhone withProperties:nil];
            break;
        case KISSMetricsStatistic_RepeatUser:
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSRepeatUserPhone withProperties:nil];
            break;
        case KISSMetricsStatistic_PerformQuery:
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSPerformQueryPhone withProperties:self.metrics];
            break;
        case KISSMetricsStatistic_WatchVideo:
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSWatchVideoPhone withProperties:self.metrics];
            break;
        case KISSMetricsStatistic_Share:
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSSharePhone withProperties:self.metrics];
            break;
        default:
            break;
    }
}


@end

//
//  VideoPlayerViewController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/21/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "VideoPlayerContainerViewController.h"
#import "AsynchronousFreeloader.h"

@interface VideoPlayerViewController ()

@property (strong, nonatomic) NSArray *video;
@property (strong, nonatomic) VideoPlayerContainerViewController *videoPlayerContainerViewController;

- (void)cancelButtonAction;

@end

@implementation VideoPlayerViewController
@synthesize video = _video;
@synthesize videoPlayerContainerViewController = _videoPlayerContainerViewController;
@synthesize loadingVideoView = _loadingVideoView;

- (id)initWithVideo:(NSArray *)video andVideoPlayerContainerViewController:(VideoPlayerContainerViewController *)videoPlayerContainerViewController
{
    if (self = [super init] ) {

        self.videoPlayerContainerViewController = videoPlayerContainerViewController;
        self.video = video;
    
    }
    
    return self;
}


- (void)processNotification:(NSNotification*)notification
{
    NSLog(@"Notification: %@", notification.name);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createLoadingVideoViewForVideo:self.video];
}


#pragma mark - Public Methods
- (void)modifyVideoPlayerButtons
{
    
    if ( ![self.videoPlayerContainerViewController controllsModified] ) {
        
    NSArray *versionCompatibility = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if ( 6 == [[versionCompatibility objectAtIndex:0] intValue] ) { /// iOS 6 is installed
        
        UIButton *previousVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] subviews] objectAtIndex:0] subviews] objectAtIndex:1];
        [previousVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];
        
        UIButton *nextVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] subviews] objectAtIndex:0] subviews] objectAtIndex:2];
        [nextVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [nextVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchDown];
        
    
    } else { /// iOS 5 is installed
    
        // Video Player Controls
        UIButton *previousVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:1];
        [previousVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];

        UIButton *nextVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:2];
        [nextVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [nextVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchDown];
    
    }

        [self.videoPlayerContainerViewController setControllsModified:YES];
        
    }
}

- (void)createLoadingVideoViewForVideo:(NSArray*)video;
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    if (self.loadingVideoView) {
      
        [self.loadingVideoView removeFromSuperview];
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    }
 
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingVideoView" owner:self options:NULL];
    self.loadingVideoView = [nib objectAtIndex:0];
    self.loadingVideoView.videoTitleLabel.text = [NSString stringWithFormat:@"%@", [video valueForKey:@"title"]];
    [self.loadingVideoView.loadingCancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [AsynchronousFreeloader loadImageFromLink:[video valueForKey:@"thumbnail_url"] forImageView:self.loadingVideoView.thumbnailImageView withPlaceholderView:nil];
    [self.view addSubview:self.loadingVideoView];
    [self.view addSubview:self.videoPlayerContainerViewController.webView];
    
    CGRect frame = self.view.bounds;
    
    if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) {
    
        NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.videoPlayerContainerViewController.query, KISSQuery, [self.video valueForKey:@"title"], KISSVideoTitle, nil];
        [[KISSMetricsAPI sharedAPI] recordEvent:KISSWatchVideoInPortraitPhone withProperties:metrics];
        
        [self.loadingVideoView setFrame:CGRectMake(0.0f, 120.0f, frame.size.width, frame.size.height)];
        
    } else {
        
        NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.videoPlayerContainerViewController.query, KISSQuery, [self.video valueForKey:@"title"], KISSVideoTitle, nil];
        [[KISSMetricsAPI sharedAPI] recordEvent:KISSWatchVideoInLandscapePhone withProperties:metrics];
        
        [self.loadingVideoView setFrame:CGRectMake(80.0f, 30.0f, frame.size.height, frame.size.width)];
        
    }
    
    
}

#pragma mark - Private Methods
- (void)cancelButtonAction
{
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.videoPlayerContainerViewController.query, KISSQuery, [self.video valueForKey:@"title"], KISSVideoTitle, nil];
    [[KISSMetricsAPI sharedAPI] recordEvent:KISSCancelVideoPhone withProperties:metrics];
    
    [self.videoPlayerContainerViewController destroyMoviePlayer];
}

#pragma mark - Interface Orientation Methods
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.loadingVideoView) {
        
        CGRect frame = self.view.bounds;
        
        if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) {
            
            NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.videoPlayerContainerViewController.query, KISSQuery, [self.video valueForKey:@"title"], KISSVideoTitle, nil];
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSWatchVideoInPortraitPhone withProperties:metrics];
            
            [self.loadingVideoView setFrame:CGRectMake(0.0f, 120.0f, frame.size.width, frame.size.height)];
            
        } else {
            
            NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.videoPlayerContainerViewController.query, KISSQuery, [self.video valueForKey:@"title"], KISSVideoTitle, nil];
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSWatchVideoInLandscapePhone withProperties:metrics];
            
            [self.loadingVideoView setFrame:CGRectMake(80.0f, 30.0f, frame.size.height, frame.size.width)];
        }        
    }
}

@end
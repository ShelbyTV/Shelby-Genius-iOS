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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self createLoadingVideoViewForVideo:self.video];
    
}


#pragma mark - Public Methods
- (void)modifyVideoPlayerButtons
{
    // Done Button
//    UIButton *doneButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:2] subviews] objectAtIndex:3];
    
    // Video Player Controls
    UIButton *previousVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:1];
    [previousVideoButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];
    
    UIButton *nextVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    [nextVideoButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [nextVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchDown];
}

- (void)createLoadingVideoViewForVideo:(NSArray*)video;
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingVideoView" owner:self options:NULL];
    self.loadingVideoView = [nib objectAtIndex:0];
    self.loadingVideoView.videoTitleLabel.text = [NSString stringWithFormat:@"%@", [video valueForKey:@"title"]];
    [self.loadingVideoView.loadingCancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [AsynchronousFreeloader loadImageFromLink:[video valueForKey:@"thumbnail_url"] forImageView:self.loadingVideoView.thumbnailImageView withPlaceholderView:nil];
    [self.view addSubview:self.loadingVideoView];
    
    CGRect frame = self.view.bounds;
    
    if ( UIDeviceOrientationIsPortrait(self.interfaceOrientation) ) {
    
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
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if (self.loadingVideoView) {
     
        CGRect frame = self.view.bounds;
        
        if ( UIDeviceOrientationIsPortrait(self.interfaceOrientation) ) {
            
            NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.videoPlayerContainerViewController.query, KISSQuery, [self.video valueForKey:@"title"], KISSVideoTitle, nil];
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSWatchVideoInPortraitPhone withProperties:metrics];
            
            [self.loadingVideoView setFrame:CGRectMake(0.0f, 120.0f, frame.size.width, frame.size.height)];
            
        } else {
            
            NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.videoPlayerContainerViewController.query, KISSQuery, [self.video valueForKey:@"title"], KISSVideoTitle, nil];
            [[KISSMetricsAPI sharedAPI] recordEvent:KISSWatchVideoInLandscapePhone withProperties:metrics];
            
            [self.loadingVideoView setFrame:CGRectMake(80.0f, 30.0f, frame.size.height, frame.size.width)];
        }
        
    }
    
    return interfaceOrientation;
}

@end

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
#import "AppDelegate.h"

@interface VideoPlayerViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *video;
@property (assign, nonatomic) BOOL fullscreenButtonAdded;

- (void)toggleFullscreen:(id)sender;

@end

@implementation VideoPlayerViewController
@synthesize appDelegate = _appDelegate;
@synthesize video = _video;
@synthesize videoPlayerContainerViewController = _videoPlayerContainerViewController;
@synthesize loadingVideoView = _loadingVideoView;
@synthesize fullscreenButtonAdded = _fullscreenButtonAdded;

- (id)initWithVideo:(NSArray *)video andVideoPlayerContainerViewController:(VideoPlayerContainerViewController *)videoPlayerContainerViewController
{
    if (self = [super init] ) {

        self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        self.videoPlayerContainerViewController = videoPlayerContainerViewController;
        self.video = video;
        
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ( kSystemVersion6 && !kDeviceIsIPad ) { // iOS6 and iPhone
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];    
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self createLoadingVideoViewForVideo:self.video];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

#pragma mark - Public Methods
- (void)modifyVideoPlayerButtons
{

    if ( kSystemVersion6 ) { 

        if ( kDeviceIsIPad ) { // iOS 6 and iPad
            
            // View for MPMoviePLayer Controls
            UIView *transportControlsView = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] subviews] objectAtIndex:1] subviews] objectAtIndex:0];
            
            // Modify button with left arrows
            UIButton *previousVideoButton = [[transportControlsView subviews] objectAtIndex:0];
            [previousVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
            // Modify button with right arrows
            UIButton *nextVideoButton = [[transportControlsView subviews] objectAtIndex:2];
            [nextVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [nextVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchDown];

            // Add fullscreen button to left side of previous button
            if ( ![self fullscreenButtonAdded] ) {
                
                self.fullscreenButtonAdded = YES;
            
                
                CGRect frame = previousVideoButton.frame;
                UIButton *fullscreenButton = [[UIButton alloc] init];
                [fullscreenButton setFrame:CGRectMake(-60.0f+frame.origin.x, frame.origin.y, 40.0f, 42.0f)];
                [fullscreenButton setBackgroundImage:[UIImage imageNamed:@"fullscreenButton"] forState:UIControlStateNormal];
                [fullscreenButton addTarget:self action:@selector(toggleFullscreen:) forControlEvents:UIControlEventTouchUpInside];
                
                if ( self.appDelegate.rootSplitViewController.isShowingMaster ) {
                    
                    if ( [transportControlsView.subviews count] <= 5 ) [transportControlsView addSubview:fullscreenButton];
                    
                } else {
                    
                    if ( [transportControlsView.subviews count] <= 5 ) [transportControlsView addSubview:fullscreenButton];
                    
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.1];
                    fullscreenButton.transform = CGAffineTransformMakeRotation(M_PI);
                    [UIView commitAnimations];
                    
                    
                }

                
            }

            
        } else { // iOS 6 and iPhone
        
            UIButton *previousVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] subviews] objectAtIndex:0] subviews] objectAtIndex:1];
            [previousVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
            UIButton *nextVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] subviews] objectAtIndex:0] subviews] objectAtIndex:2];
            [nextVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [nextVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
        }
        
    
    } else { 
        
        if ( kDeviceIsIPad ) { // iOS 5 and iPad
            
            UIButton *previousVideoButton = [[[[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:1] subviews] objectAtIndex:0] subviews] objectAtIndex:0];
            [previousVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
            UIButton *nextVideoButton = [[[[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:1] subviews] objectAtIndex:0] subviews] objectAtIndex:2];
            [nextVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [nextVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
        } else { // iOS 5 and iPhone
            
            UIButton *previousVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:1];
            [previousVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
            UIButton *nextVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:2];
            [nextVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [nextVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchDown];
        
        }
        
    }
}

- (void)createLoadingVideoViewForVideo:(NSArray*)video;
{

    // Remove previous loadingVideoView if it exists
    if (self.loadingVideoView) {
        
        [self.loadingVideoView removeFromSuperview];
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
        
    }

    // Create new instance of loadingVideoView
    NSArray *nib;
    
    if ( kDeviceIsIPad ) {
        
        nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingVideoView_ipad" owner:self options:NULL];
        
        // Set iPad specific settings
        self.fullscreenButtonAdded = NO;
        
    } else {

        nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingVideoView_iphone" owner:self options:NULL];
        
        // Set iPhone specific settings
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }

    self.loadingVideoView = [nib objectAtIndex:0];
    self.loadingVideoView.videoTitleLabel.text = [NSString stringWithFormat:@"%@", [video valueForKey:@"title"]];
    [self.loadingVideoView.loadingCancelButton addTarget:self.videoPlayerContainerViewController action:@selector(destroyMoviePlayer) forControlEvents:UIControlEventTouchUpInside];
    [AsynchronousFreeloader loadImageFromLink:[video valueForKey:@"thumbnail_url"] forImageView:self.loadingVideoView.thumbnailImageView withPlaceholderView:nil];
    [self.view addSubview:self.loadingVideoView];
    [self.view addSubview:self.videoPlayerContainerViewController.webView];
    self.loadingVideoView.center = self.view.center;
    
    CGRect frame = self.view.bounds;
    
    if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) {
        
       if ( !kDeviceIsIPad ) [self.loadingVideoView setFrame:CGRectMake(0.0f, 120.0f, frame.size.width, frame.size.height)];
        
    } else {
        
       if ( !kDeviceIsIPad ) [self.loadingVideoView setFrame:CGRectMake(80.0f, 30.0f, frame.size.height, frame.size.width)];
        
    }
    
    
    
}

#pragma mark - Private Methods
- (void)toggleFullscreen:(id)sender
{
    
    [self.appDelegate.rootSplitViewController toggleMasterView:self];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.1];
//    self.fullscreenButton.transform = CGAffineTransformMakeRotation(M_PI);
//    [UIView commitAnimations];

}

#pragma mark - Remote Control Event
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    
    switch ( event.subtype ) {
        case UIEventSubtypeRemoteControlTogglePlayPause:{
        
            if ( self.moviePlayer.playbackState == MPMoviePlaybackStatePaused || self.moviePlayer.playbackState == MPMoviePlaybackStateStopped || self.moviePlayer.playbackState == MPMoviePlaybackStateInterrupted ) {
                [self.moviePlayer play];
            } else {
                [self.moviePlayer pause];
            }
            
        } break;
        case UIEventSubtypeRemoteControlNextTrack:{
            [self.videoPlayerContainerViewController nextVideoButtonAction];
        } break;
        case UIEventSubtypeRemoteControlPreviousTrack:{
            [self.videoPlayerContainerViewController previousVideoButtonAction];
        } break;
        default:
            break;
    }
    
}

#pragma mark - Interface Orientation Methods
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.loadingVideoView) {
        
        CGRect frame = self.view.bounds;
        
        if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) {

            if ( !kDeviceIsIPad ) [self.loadingVideoView setFrame:CGRectMake(0.0f, 120.0f, frame.size.width, frame.size.height)];
            
        } else {
            
            if ( !kDeviceIsIPad )  [self.loadingVideoView setFrame:CGRectMake(80.0f, 30.0f, frame.size.height, frame.size.width)];
        }        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ( kDeviceIsIPad) {
        return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
    } else {
        return interfaceOrientation;
    }
}

@end
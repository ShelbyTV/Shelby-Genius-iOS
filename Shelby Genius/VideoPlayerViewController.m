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
    
    if ( kSystemVersion6 && !kDeviceIsIPad ) { // iOS6 and iPhone
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    
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

            // Modify navigation bar
            UINavigationBar *navigationBar = [[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] subviews] objectAtIndex:0];
            CGRect navFrame = navigationBar.frame;
            if (navFrame.origin.y != 0.0f ) {
                navigationBar.frame = CGRectMake(navFrame.origin.x, -20.f + navFrame.origin.y, navFrame.size.width, navFrame.size.height);
            }
            
            // Add fullscreen button to left side of previous button
            if ( ![self fullscreenButtonAdded] ) {

                self.fullscreenButtonAdded = YES;
                
                CGRect frame = previousVideoButton.frame;
                UIButton *fullscreenButton = [[UIButton alloc] init];
                [fullscreenButton setFrame:CGRectMake(-58.0f+frame.origin.x, 1.0f + frame.origin.y, 25.0f, 23.0f)];
   
                if ( [self.appDelegate.rootSplitViewController isShowingMaster]) {
                    [fullscreenButton setBackgroundImage:[UIImage imageNamed:kEnterFullscreen] forState:UIControlStateNormal];
                } else {
                    [fullscreenButton setBackgroundImage:[UIImage imageNamed:kExitFullscreen] forState:UIControlStateNormal];
                }

                [fullscreenButton addTarget:self action:@selector(toggleFullscreen:) forControlEvents:UIControlEventTouchUpInside];
                
                if ( [transportControlsView.subviews count] <= 5 ) [transportControlsView addSubview:fullscreenButton];

                
            }
            
        } else { // iOS 6 and iPhone
        
            // View for MPMoviePLayer Controls
            UIView *transportControlsView = [[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] subviews] objectAtIndex:0];
            
            // Modify button with left arrows
            UIButton *previousVideoButton = [transportControlsView.subviews objectAtIndex:1];
            [previousVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
            // Modify button with right arrows
            UIButton *nextVideoButton = [transportControlsView.subviews objectAtIndex:2];
            [nextVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [nextVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
        }
        
    
    } else { 
        
        if ( kDeviceIsIPad ) { // iOS 5 and iPad
            
            // View for MPMoviePLayer Controls
            UIView *transportControlsView = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:1] subviews] objectAtIndex:0];
            
            // Modify button with left arrows
            UIButton *previousVideoButton = [[transportControlsView subviews] objectAtIndex:0];
            [previousVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
            // Modify button with right arrows
            UIButton *nextVideoButton = [[transportControlsView subviews] objectAtIndex:2];
            [nextVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [nextVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
            // Modify navigation bar
            UINavigationBar *navigationBar = [[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0];
            CGRect navFrame = navigationBar.frame;
            if (navFrame.origin.y != 0.0f ) {
                navigationBar.frame = CGRectMake(navFrame.origin.x, -20.f + navFrame.origin.y, navFrame.size.width, navFrame.size.height);
            }
            
            // Add fullscreen button to left side of previous button
            if ( ![self fullscreenButtonAdded] ) {
                
                self.fullscreenButtonAdded = YES;
                
                CGRect frame = previousVideoButton.frame;
                
                UIButton *fullscreenButton = [[UIButton alloc] init];
                [fullscreenButton setFrame:CGRectMake(-58.0f+frame.origin.x, 1.0f + frame.origin.y, 25.0f, 23.0f)];
                
                if ( [self.appDelegate.rootSplitViewController isShowingMaster]) {
                    [fullscreenButton setBackgroundImage:[UIImage imageNamed:kEnterFullscreen] forState:UIControlStateNormal];
                } else {
                    [fullscreenButton setBackgroundImage:[UIImage imageNamed:kExitFullscreen] forState:UIControlStateNormal];
                }
                
                [fullscreenButton addTarget:self action:@selector(toggleFullscreen:) forControlEvents:UIControlEventTouchUpInside];
                
                if ( [transportControlsView.subviews count] <= 5 ) [transportControlsView addSubview:fullscreenButton];

                
            }
            
        } else { // iOS 5 and iPhone
            
            // View for MPMoviePLayer Controls
            UIView *transportControlsView = [[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] ;
            
            // Modify button with left arrows
            UIButton *previousVideoButton = [transportControlsView.subviews objectAtIndex:1];
            [previousVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
            // Modify button with right arrows
            UIButton *nextVideoButton = [transportControlsView.subviews objectAtIndex:2];
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

    // Draw loadingVideoView
    self.loadingVideoView = [nib objectAtIndex:0];
    self.loadingVideoView.videoTitleLabel.text = [NSString stringWithFormat:@"%@", [video valueForKey:@"title"]];
    [self.loadingVideoView.loadingCancelButton addTarget:self.videoPlayerContainerViewController action:@selector(destroyMoviePlayer) forControlEvents:UIControlEventTouchUpInside];
    [AsynchronousFreeloader loadImageFromLink:[video valueForKey:@"thumbnail_url"] forImageView:self.loadingVideoView.thumbnailImageView withPlaceholderView:nil];
    [self.view addSubview:self.loadingVideoView];
    [self.view addSubview:self.videoPlayerContainerViewController.webView];
    
    // Set Orientation
    if ( kDeviceIsIPad ) {
    
        self.loadingVideoView.center = self.view.center;
        
    } else {
     
        CGRect frame = self.view.bounds;
        
        if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) {
            
            [self.loadingVideoView setFrame:CGRectMake(self.view.center.x - self.loadingVideoView.center.x, self.view.center.y - self.loadingVideoView.center.y, frame.size.width, frame.size.height)];
            
        } else {
            
            [self.loadingVideoView setFrame:CGRectMake(self.view.center.x - self.loadingVideoView.center.x, self.view.center.y - self.loadingVideoView.center.y, frame.size.height, frame.size.width)];
            
        }
        
    }
    
}

#pragma mark - Private Methods
- (void)toggleFullscreen:(id)sender
{
    [self.appDelegate.rootSplitViewController toggleMasterView:self];
    
    if ( [self.appDelegate.rootSplitViewController isShowingMaster]) {
        [(UIButton*)sender  setBackgroundImage:[UIImage imageNamed:kEnterFullscreen] forState:UIControlStateNormal];
    } else {
        [(UIButton*)sender  setBackgroundImage:[UIImage imageNamed:kExitFullscreen] forState:UIControlStateNormal];
    }
    
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
    if (self.loadingVideoView && !kDeviceIsIPad) { // Such an ugly solution (Support Non-Retina, Retina 3.5", and Retina 4" for iPhone)
        
        if ( [[UIScreen mainScreen] respondsToSelector: @selector(scale)] ) {

            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 1136) {
                
                CGRect frame = self.view.bounds;
                if ( UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ) {
                    [self.loadingVideoView setFrame:CGRectMake(0.0f, 144.0f, frame.size.width, frame.size.height)];
                } else {
                    [self.loadingVideoView setFrame:CGRectMake(124.0f, 30.0f, frame.size.height, frame.size.width)];
                }
                
            } else{
                
                CGRect frame = self.view.bounds;
                if ( UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ) { 
                    [self.loadingVideoView setFrame:CGRectMake(0.0f, 120.0f, frame.size.width, frame.size.height)];
                } else {
                    [self.loadingVideoView setFrame:CGRectMake(80.0f, 30.0f, frame.size.height, frame.size.width)];
                }
            }
    
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
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

- (void)viewWillAppear:(BOOL)animated
{
    if ( 6 == kSystemVersion ) [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
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
    
    if ( ![self.videoPlayerContainerViewController controllsModified] ) {
        
    if ( 6 == kSystemVersion) { /// iOS 6 is installed

        if ( kDeviceIsIPad ) { // iOS 6 and iPad
            
            UIButton *previousVideoButton = [[[[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] subviews] objectAtIndex:1] subviews] objectAtIndex:0] subviews] objectAtIndex:0];
            [previousVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
            UIButton *nextVideoButton = [[[[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] subviews] objectAtIndex:1] subviews] objectAtIndex:0] subviews] objectAtIndex:2];
            [nextVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [nextVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
        } else { // // iOS 6 and iPhone
        
            UIButton *previousVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] subviews] objectAtIndex:0] subviews] objectAtIndex:1];
            [previousVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [previousVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
            UIButton *nextVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] subviews] objectAtIndex:0] subviews] objectAtIndex:2];
            [nextVideoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [nextVideoButton addTarget:self.videoPlayerContainerViewController action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchDown];
            
        }
        
    
    } else { /// iOS 5 is installed
        
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
 
    NSArray *nib;
    
    if ( kDeviceIsIPad ) {
        
        nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingVideoView_ipad" owner:self options:NULL];
        
    } else {
        
        nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingVideoView_iphone" owner:self options:NULL];
        
    }
    

    self.loadingVideoView = [nib objectAtIndex:0];
    self.loadingVideoView.videoTitleLabel.text = [NSString stringWithFormat:@"%@", [video valueForKey:@"title"]];
    [self.loadingVideoView.loadingCancelButton addTarget:self.videoPlayerContainerViewController action:@selector(destroyMoviePlayer) forControlEvents:UIControlEventTouchUpInside];
    [AsynchronousFreeloader loadImageFromLink:[video valueForKey:@"thumbnail_url"] forImageView:self.loadingVideoView.thumbnailImageView withPlaceholderView:nil];
    [self.view addSubview:self.loadingVideoView];
    [self.view addSubview:self.videoPlayerContainerViewController.webView];
    
    CGRect frame = self.view.bounds;
    
    if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) {
        
       if ( kDeviceIsIPhone ) [self.loadingVideoView setFrame:CGRectMake(0.0f, 120.0f, frame.size.width, frame.size.height)];
        
    } else {
        
       if ( kDeviceIsIPhone ) [self.loadingVideoView setFrame:CGRectMake(80.0f, 30.0f, frame.size.height, frame.size.width)];
        
    }
    
    
}

#pragma mark - Remote Control Event
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    
    switch ( event.subtype ) {
        case UIEventSubtypeRemoteControlTogglePlayPause:{
        
            if ( self.moviePlayer.playbackState == MPMoviePlaybackStatePaused || self.moviePlayer.playbackState == MPMoviePlaybackStateStopped || self.moviePlayer.playbackState == MPMoviePlaybackStateInterrupted ) [self.moviePlayer play];
            
            else [self.moviePlayer pause];
        
        } break;
        case UIEventSubtypeRemoteControlNextTrack:{
            NSLog(@"NEXT");
            [self.videoPlayerContainerViewController nextVideoButtonAction];
        } break;
        case UIEventSubtypeRemoteControlPreviousTrack:{
            NSLog(@"PREVIOUS");
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

            if ( kDeviceIsIPhone ) [self.loadingVideoView setFrame:CGRectMake(0.0f, 120.0f, frame.size.width, frame.size.height)];
            
        } else {
            
            if ( kDeviceIsIPhone )  [self.loadingVideoView setFrame:CGRectMake(80.0f, 30.0f, frame.size.height, frame.size.width)];
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
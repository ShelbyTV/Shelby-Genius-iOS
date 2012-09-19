//
//  VideoPlayerContainerViewController.m
//  Shelby-tv
//
//  Created by Arthur Ariel Sabintsev on 7/26/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoPlayerContainerViewController.h"

// Frameworks
#import <MediaPlayer/MediaPlayer.h>

// External Libraries
#import "AsynchronousFreeloader.h"

// Models
#import "AppDelegate.h"

// View Controllers
#import "VideoPlayerViewController.h"

@interface VideoPlayerContainerViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (assign, nonatomic) VideoProvider provider;
@property (strong, nonatomic) VideoPlayerViewController *moviePlayer;
@property (strong, nonatomic) NSArray *video;
@property (assign, nonatomic) BOOL videoWillBegin;

- (void)createMoviePlayer;
- (void)createWebView;
- (void)createObservers;
- (void)videoDirectLinkFromProvider:(NSString*)providerName;
- (void)loadYouTubePage;
- (void)loadVimeoPage;
- (void)loadDailyMotionPage;
- (void)loadNewlySelectedVideo;
- (void)playVideo:(NSString *)link;
- (void)processNotification:(NSNotification*)notification;
- (void)videoDidLoad:(NSNotification*)notification;
- (void)controllsDidAppear:(NSNotification*)notification;
- (void)videoBeganStreamingOverAirPlay:(NSNotification*)notification;

@end

@implementation VideoPlayerContainerViewController
@synthesize videos = _videos;
@synthesize selectedVideo = _selectedVideo;
@synthesize query = _query;
@synthesize appDelegate = _appDelegate;
@synthesize video = _video;
@synthesize provider = _provider;
@synthesize moviePlayer = _moviePlayer;
@synthesize webView = _webView;
@synthesize videoWillBegin = _videoWillBegin;

#pragma mark - Initialization
- (id)initWithVideos:(NSMutableArray *)videos selectedVideo:(NSUInteger)selectedVideo andQuery:(NSString *)query
{
    
    if ( self = [super init]) {
        
        // Create references
        self.query = query;
        self.videos = videos;
        self.selectedVideo = selectedVideo;
        self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        // Select initial video
        self.video = [[self.videos objectAtIndex:self.selectedVideo] valueForKey:@"video"];
        self.videoWillBegin = NO;
        
        // Obtain direct link to video based on video provider
        [self videoDirectLinkFromProvider:[self.video valueForKey:@"provider_name"]];
        
    }
    
    return self;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createMoviePlayer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Subview Creation Methods
- (void)createMoviePlayer
{
    self.moviePlayer = [[VideoPlayerViewController alloc] initWithVideo:self.video andVideoPlayerContainerViewController:self];
    
    self.moviePlayer.moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    if ( kDeviceIsIPad) {
        [self.moviePlayer.view setFrame:[[[self.appDelegate.rootSplitViewController.viewControllers objectAtIndex:1] view] frame]];
        [self.appDelegate.detailNavigationController pushViewController:self.moviePlayer animated:NO];
    } else {
        [self.moviePlayer.view setFrame:self.appDelegate.window.frame];
        [self.navigationController pushViewController:self.moviePlayer animated:NO];
        [self.navigationController setNavigationBarHidden:YES];
    }

    if ( kSystemVersion5 ) [self.moviePlayer modifyVideoPlayerButtons];
    
    [self.appDelegate setVideoPlayerViewController:self.moviePlayer];
    
}

- (void)destroyMoviePlayer
{
    NSUInteger numberOfViewControllers = [self.navigationController.viewControllers count];
    [self.moviePlayer.view setHidden:YES];
    
    if ( kDeviceIsIPad ) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    } else {
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:numberOfViewControllers-3] animated:YES];
    }

    [self.navigationController.visibleViewController viewWillAppear:NO]; // Redraw instance of GeniusRollViewControlelr in case navigationBar gets shifted in the wrong direction (potential solution)
    [self.moviePlayer.moviePlayer stop];
    [self.moviePlayer.moviePlayer setContentURL:nil];
    [self setMoviePlayer:nil];
    [self.appDelegate setVideoPlayerViewController:nil];
    
}

- (void)createWebView
{
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(159.0f, 239.0f, 2.0f, 2.0f)];
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    self.webView.mediaPlaybackAllowsAirPlay = NO;
    self.webView.hidden = YES;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


#pragma mark - Video Loading Methods
- (void)videoDirectLinkFromProvider:(NSString *)providerName
{
    
    // Create webView
    [self createWebView];

    // Choose link extraction method based on video provider
    if ( [providerName isEqualToString:@"vimeo"] ) {
        
        [self setProvider:VideoProvider_Vimeo];
        [self loadVimeoPage];
        
    } else if ( [providerName isEqualToString:@"youtube"] ) {
        
        [self setProvider:VideoProvider_YouTube];
        [self loadYouTubePage];
        
    } else if ( [providerName isEqualToString:@"dailymotion"] ) {
        
        [self setProvider:VideoProvider_DailyMotion];
        [self loadDailyMotionPage];
    }
    
}

- (void)loadVimeoPage
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:nil object:nil];
    
    static NSString *vimeoExtractor = @"<html><body><center><iframe id=\"player_1\" src=\"http://player.vimeo.com/video/%@?api=1&amp;player_id=player_1\" webkit-playsinline ></iframe><script src=\"http://a.vimeocdn.com/js/froogaloop2.min.js?cdbdb\"></script><script>(function(){var vimeoPlayers = document.querySelectorAll('iframe');$f(vimeoPlayers[0]).addEvent('ready', ready);function ready(player_id) {$f(player_id).api('play');}})();</script></center></body></html>";
    
    
    NSString *vimeoRequestString = [NSString stringWithFormat:vimeoExtractor, [self.video valueForKey:@"provider_id"]];
    
    [self.moviePlayer.loadingVideoView addSubview:self.webView];
    [self.webView loadHTMLString:vimeoRequestString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
    
}

- (void)loadYouTubePage
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:nil object:nil];
    
    static NSString *youtubeExtractor = @"<html><body><div id=\"player\"></div><script>var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { height: '1', width: '1', videoId: '%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script></body></html>​";
    
    NSString *youtubeRequestString = [NSString stringWithFormat:youtubeExtractor, [self.video valueForKey:@"provider_id"]];
    
    [self.moviePlayer.loadingVideoView addSubview:self.webView];
    [self.webView loadHTMLString:youtubeRequestString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
    
}

- (void)loadDailyMotionPage
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:nil object:nil];
    
    static NSString *dailymotionExtractor = @"<html><body><div id=\"player\"></div><script>(function(){var e=document.createElement('script');e.async=true;e.src='http://api.dmcdn.net/all.js';var s=document.getElementsByTagName('script')[0];s.parentNode.insertBefore(e, s);}());window.dmAsyncInit=function(){var player=DM.player(\"player\",{video: \"%@\", width: \"480\", height: \"269\", params:{api: postMessage}});player.addEventListener(\"apiready\", function(e){e.target.play();});};</script></body></html>";
    
    NSString *dailymotionRequestString = [NSString stringWithFormat:dailymotionExtractor, [self.video valueForKey:@"provider_id"]];
    
    [self.moviePlayer.loadingVideoView addSubview:self.webView];
    [self.webView loadHTMLString:dailymotionRequestString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
}

- (void)playVideo:(NSString *)link
{
    
    if ( ![self videoWillBegin]) {
        
        self.videoWillBegin = YES;
    
        // Create MPMoviePlayer related Observers
        [self createObservers];
        
        // Load Video
        [self.moviePlayer.moviePlayer setContentURL:[NSURL URLWithString:link]];
        [self.moviePlayer.moviePlayer setShouldAutoplay:YES];
        [self.moviePlayer.moviePlayer prepareToPlay];
        [self.moviePlayer.moviePlayer play];
        
        // Add Video Info to Lockscreen
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        NSString *videoTitle = [self.video valueForKey:@"title"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:videoTitle forKey:MPMediaItemPropertyTitle];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dictionary];
        
        // KISSMetrics
        NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.query, KISSQuery, [self.video valueForKey:@"title"], KISSVideoTitle, nil];
        [[KISSMetricsController sharedInstance] sendActionToKISSMetrics:KISSMetricsStatistic_WatchVideo andMetrics:metrics];
    }
}

#pragma mark - Video Player Actions
- (void)previousVideoButtonAction
{
    
    if ( self.selectedVideo > 0 ) {
        
        // Reference previous video
        self.selectedVideo -= 1;
        [self loadNewlySelectedVideo];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"You are currently watching the first video recommended by Genius."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil, nil];
        [alertView show];

    }
    
}

- (void)nextVideoButtonAction
{
    if ( self.selectedVideo < [self.videos count]-1 ) {
        
        // Reference next video
        self.selectedVideo += 1;
        [self loadNewlySelectedVideo];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"You are currently watching the last video recommended by Shelby Genius."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }
    
}

- (void)loadNewlySelectedVideo
{
    // Unload current video
    [self.moviePlayer.moviePlayer stop];
    [self.moviePlayer.moviePlayer setContentURL:nil];
    self.videoWillBegin = NO;

    // Scroll GeniusRollViewController to row of video that will be loaded
    NSNumber *rowNumber = [NSNumber numberWithInt:self.selectedVideo];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:rowNumber forKey:kIndexOfCurrentVideo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIndexOfCurrentVideoObserver
                                                        object:nil
                                                      userInfo:dictionary];
    
    // Create loadingVideoView for new video
    self.video = nil;
    self.video = [[self.videos objectAtIndex:self.selectedVideo] valueForKey:@"video"];
    [self.moviePlayer createLoadingVideoViewForVideo:self.video];
    
    // Get direct link to video based on video provider
    [self createWebView];
    NSString *providerName = [self.video valueForKey:@"provider_name"];
    [self videoDirectLinkFromProvider:providerName];
}


#pragma mark - Observer Methods
- (void)createObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidLoad:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidEndPlaying:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoBeganStreamingOverAirPlay:)
                                                 name:MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification
                                               object:nil];
    
    if ( kSystemVersion6 ) {
        
        NSString *controlAppearanceNotification = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"U",@"I",@"V",@"i",@"e",@"w",@"A",@"n",@"i",@"m",@"a",@"t",@"i",@"o",@"n",@"D",@"i",@"d",@"C",@"o",@"m",@"m",@"i",@"t",@"N",@"o",@"t",@"i",@"f",@"i",@"c",@"a",@"t",@"i",@"o",@"n"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(controllsDidAppear:)
                                                     name:controlAppearanceNotification
                                                   object:nil];
        
    }
    
}

- (void)processNotification:(NSNotification *)notification
{
    
    if ( notification.userInfo && ![notification.userInfo isKindOfClass:[NSNull class]] ) {
        
        NSArray *allValues = [notification.userInfo allValues];
        
        for (id value in allValues) {
            
            SEL pathSelector = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@", @"p",@"a",@"t",@"h"]);
            
            if ([value respondsToSelector:pathSelector]) {
                
                // Remove myself as an observer -- otherwise we could initiate 'playVideo' multiple times, slowing down video display
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                
                // Remove webView
                [self.webView stopLoading];
                [self.webView removeFromSuperview];
                
                // Get URL
                NSString *path = [value performSelector:pathSelector];
                
                // Launch moviePlayer
                [self playVideo:path];
                
              
            }
        }
        
    }

}

- (void)videoDidLoad:(NSNotification *)notification
{
    MPMoviePlayerController *movieController = notification.object;
    
    if ( movieController.loadState != 0 ) {
        
        
        // Remove Indicator
        [self.moviePlayer.loadingVideoView.indicator stopAnimating];
        
        // Remove Loading Screen
        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             [self.moviePlayer.loadingVideoView setAlpha:0.0f];
                             
                         } completion:^(BOOL finished) {

                             movieController.controlStyle = MPMovieControlStyleFullscreen;
                             
                         }];
    }
    
}

- (void)controllsDidAppear:(NSNotification *)notification
{

    if ( 4 == [[[[[[self.moviePlayer.view subviews] objectAtIndex:0] subviews] objectAtIndex:0] subviews] count] ) {

        NSString *overlayString;
        
        // Listen to device-specific notification
        if ( kDeviceIsIPad ) {
            overlayString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"M",@"P",@"P",@"a",@"d",@"F",@"u",@"l",@"l",@"S",@"c",@"r",@"e",@"e",@"n",@"V",@"i",@"d",@"e",@"o",@"O",@"v",@"e",@"r",@"l",@"a",@"y"];

        } else {
            
             overlayString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"M",@"P",@"F",@"u",@"l",@"l",@"S",@"c",@"r",@"e",@"e",@"n",@"V",@"i",@"d",@"e",@"o",@"O",@"v",@"e",@"r",@"l",@"a",@"y"];
        
        }

        NSString *classNameCheck = NSStringFromClass([[[[[[[self.moviePlayer.view subviews] objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:3] class]);
        
        // If 'overlayString' notification is posted, the mdeia player buttons are visible, so we can modify them.
        if ( [classNameCheck isEqualToString:overlayString] ) {
            [self.moviePlayer modifyVideoPlayerButtons];
        }
    
        // Show/Hide status bar if iPhone
        if ( !kDeviceIsIPad ) {
           
            NSString *name = [NSString stringWithFormat:@"%@%@%@%@", @"n",@"a",@"m",@"e"];
            NSString *show = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"M",@"P",@"I",@"n",@"l",@"i",@"n",@"e",@"V",@"i",@"d",@"e",@"o",@"O",@"v",@"e",@"r",@"l",@"a",@"y",@"S",@"h",@"o",@"w"];
            NSString *hide = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"M",@"P",@"I",@"n",@"l",@"i",@"n",@"e",@"V",@"i",@"d",@"e",@"o",@"O",@"v",@"e",@"r",@"l",@"a",@"y",@"H",@"i",@"d",@"e"];
            
            if ( [[notification.userInfo valueForKey:name] isEqualToString:show] ) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            } else if ( [[notification.userInfo valueForKey:name] isEqualToString:hide] ) {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            }
        }
    }
}

- (void)videoDidEndPlaying:(NSNotification*)notification
{
    
    NSString *playbackDidFinishReason = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", @"M",@"P",@"M",@"o",@"v",@"i",@"e",@"P",@"l",@"a",@"y",@"e",@"r",@"P",@"l",@"a",@"y",@"b",@"a",@"c",@"k",@"D",@"i",@"d",@"F",@"i",@"n",@"i",@"s",@"h",@"R",@"e",@"a",@"s",@"o",@"n",@"U",@"s",@"e",@"r",@"I",@"n",@"f",@"o",@"K",@"e",@"y"];
    NSNumber *notificaitonNumber = [notification.userInfo valueForKey:playbackDidFinishReason];
    
    if ( 2 == [notificaitonNumber intValue] && (2 == self.moviePlayer.moviePlayer.playbackState || 0 == self.moviePlayer.moviePlayer.playbackState) ) { // Done button clicked in portrait mode
        
        [self destroyMoviePlayer];

    }
    
    if ( 0 == [notificaitonNumber intValue] && 2 == self.moviePlayer.moviePlayer.playbackState ) { // Movie ended without interruption
    
        [self nextVideoButtonAction];
    
    }

}

- (void)videoBeganStreamingOverAirPlay:(NSNotification*)notification
{
    MPMoviePlayerController *movieController = notification.object;
    
    if ( movieController.airPlayVideoActive ) {
        

    }
}

#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ( kDeviceIsIPad) {
        return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
    } else {
        return UIInterfaceOrientationPortrait;
    }
}

@end
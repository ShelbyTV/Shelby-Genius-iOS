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
@property (strong, nonatomic) UIWebView *webView;
@property (assign, nonatomic) BOOL videoWillBegin;

- (void)createMoviePlayer;
- (void)destroyMoviePlayer;
- (void)createWebView;
- (void)videoDirectLinkFromProvider:(NSString*)providerName;
- (void)loadYouTubePage;
- (void)loadVimeoPage;
- (void)loadDailyMotionPage;
- (void)loadNewlySelectedVideo;
- (void)playVideo:(NSString *)link;

- (void)processNotification:(NSNotification*)notification;
- (void)videoDidBeginPlaying:(NSNotification*)notification;

@end

@implementation VideoPlayerContainerViewController
@synthesize videos = _videos;
@synthesize selectedVideo = _selectedVideo;
@synthesize appDelegate = _appDelegate;
@synthesize video = _video;
@synthesize provider = _provider;
@synthesize moviePlayer = _moviePlayer;
@synthesize webView = _webView;
@synthesize videoWillBegin = _videoWillBegin;

#pragma mark - Initialization
- (id)initWithVideos:(NSMutableArray *)videos andSelectedVideo:(NSUInteger)selectedVideo
{
    
    if ( self = [super init]) {
        
        // Setup
        self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        self.videos = videos;
        self.selectedVideo = selectedVideo;
        self.video = [[self.videos objectAtIndex:self.selectedVideo] valueForKey:@"video"];
        self.videoWillBegin = NO;
        
        // Get direct link to video based on video provider
        [self createWebView];
        NSString *providerName = [self.video valueForKey:@"provider_name"];
        [self videoDirectLinkFromProvider:providerName];
        
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


#pragma mark - View and Subview Creation/Destruction Methods
- (void)createMoviePlayer
{
    self.moviePlayer = [[VideoPlayerViewController alloc] initWithVideo:self.video andVideoPlayerContainerViewController:self];
    [self.moviePlayer.view setFrame:self.appDelegate.window.frame];
    [self.navigationController pushViewController:self.moviePlayer animated:NO];
    [self.navigationController setNavigationBarHidden:YES];
    [self.moviePlayer modifyVideoPlayerButtons];
    
    [self.appDelegate setVideoPlayerViewController:self.moviePlayer];
    
}

- (void)destroyMoviePlayer
{
    [self.moviePlayer.view setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
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
    
    [self.view addSubview:self.webView];
    [self.webView loadHTMLString:vimeoRequestString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
    
}

- (void)loadYouTubePage
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:nil object:nil];
    
    static NSString *youtubeExtractor = @"<html><body><div id=\"player\"></div><script>var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { height: '1', width: '1', videoId: '%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script></body></html>​";
    
    NSString *youtubeRequestString = [NSString stringWithFormat:youtubeExtractor, [self.video valueForKey:@"provider_id"]];
    
    [self.view addSubview:self.webView];
    [self.webView loadHTMLString:youtubeRequestString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
    
}

- (void)loadDailyMotionPage
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:nil object:nil];
    
    static NSString *dailymotionExtractor = @"<html><body><div id=\"player\"></div><script>(function(){var e=document.createElement('script');e.async=true;e.src='http://api.dmcdn.net/all.js';var s=document.getElementsByTagName('script')[0];s.parentNode.insertBefore(e, s);}());window.dmAsyncInit=function(){var player=DM.player(\"player\",{video: \"%@\", width: \"480\", height: \"269\", params:{api: postMessage}});player.addEventListener(\"apiready\", function(e){e.target.play();});};</script></body></html>";
    
    NSString *dailymotionRequestString = [NSString stringWithFormat:dailymotionExtractor, [self.video valueForKey:@"provider_id"]];    
    
    [self.view addSubview:self.webView];
    [self.webView loadHTMLString:dailymotionRequestString baseURL:[NSURL URLWithString:@"http://shelby.tv"]];
}

- (void)playVideo:(NSString *)link
{
    
    if ( ![self videoWillBegin]) {
        
        self.videoWillBegin = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoDidBeginPlaying:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoDidEndPlaying:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
        [self.moviePlayer.moviePlayer setContentURL:[NSURL URLWithString:link]];
        [self.moviePlayer.moviePlayer play];
        
        [[Panhandler sharedInstance] recordEvent];
        
    }
}

#pragma mark - Observer Methods
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

- (void)videoDidBeginPlaying:(NSNotification*)notification
{
    
    MPMoviePlayerController *movieController = notification.object;
    if (movieController.playbackState == MPMoviePlaybackStatePlaying) [self.moviePlayer.loadingVideoView removeFromSuperview];

}

- (void)videoDidEndPlaying:(NSNotification*)notification
{
    
    NSNumber *notificaitonNumber = [notification.userInfo valueForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"];
    
    if ( 2 == [notificaitonNumber intValue] && (2 == self.moviePlayer.moviePlayer.playbackState || 0 == self.moviePlayer.moviePlayer.playbackState) ) { // Done button clicked in portrait mode
        
        [self destroyMoviePlayer];

    }
    
    if ( 0 == [notificaitonNumber intValue] && 2 == self.moviePlayer.moviePlayer.playbackState ) { // Movie ended without interruption
    
        [self nextVideoButtonAction];
    
    }

}

#pragma mark - VideoPlayerDelegate Methods
- (void)previousVideoButtonAction
{

    if ( self.selectedVideo > 0 ) {
        
        [self.moviePlayer.moviePlayer stop];
        self.videoWillBegin = NO;
        self.selectedVideo -= 1;
        [self loadNewlySelectedVideo];

    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"You are currently watching the first video recommended by Genius"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Thanks!"
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }

}

- (void)nextVideoButtonAction
{
    NSLog(@"%d", self.selectedVideo);
    if ( self.selectedVideo < [self.videos count]-1 ) {
       
        [self.moviePlayer.moviePlayer stop];
        self.videoWillBegin = NO;
        self.selectedVideo += 1;
        [self loadNewlySelectedVideo];
    
    } else {
        
        [self destroyMoviePlayer];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRollFramesScrollingObserver
                                                            object:nil
                                                          userInfo:nil];
        
    }
    
}

- (void)loadNewlySelectedVideo
{
    self.video = nil;
    self.video = [[self.videos objectAtIndex:self.selectedVideo] valueForKey:@"video"];
    
    // Create loadingVideoView for new video
    [self.moviePlayer.moviePlayer setContentURL:nil];
    [self.moviePlayer createLoadingVideoViewForVideo:self.video];
    
    // Get direct link to video based on video provider
    [self createWebView];
    NSString *providerName = [self.video valueForKey:@"provider_name"];
    [self videoDirectLinkFromProvider:providerName];
}

#pragma mark - Interface Orientation Method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end

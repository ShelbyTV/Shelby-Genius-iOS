//
//  VideoPlayerViewController.m
//  Shelby-tv
//
//  Created by Arthur Ariel Sabintsev on 7/26/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoPlayerViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *video;
@property (assign, nonatomic) VideoProvider provider;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UIWebView *webView;
@property (assign, nonatomic) BOOL videoWillBegin;

- (UIWebView*)createWebView;
- (UIActivityIndicatorView*)createActivityIndicator;
- (void)loadYouTubePage;
- (void)loadVimeoPage;
- (void)processNotification:(NSNotification*)notification;
- (void)playVideo:(NSString *)link;
- (void)destroy;

@end

@implementation VideoPlayerViewController
@synthesize appDelegate = _appDelegate;
@synthesize video = _video;
@synthesize provider = _provider;
@synthesize moviePlayer = _moviePlayer;
@synthesize indicator = _indicator;
@synthesize webView = _webView;
@synthesize videoWillBegin = _videoWillBegin;

#pragma mark - Initialization
- (id)initWithVideo:(NSArray *)video
{
    
    if ( self = [super init]) {
        
        self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        self.video = video;
        self.videoWillBegin = NO;
        self.indicator = [self createActivityIndicator];
        self.webView = [self createWebView];
        
        
        
        if ( [[video valueForKey:@"provider_name" ] isEqualToString:@"vimeo"] ) {
            
            [self setProvider:VideoProvider_Vimeo];
            [self loadVimeoPage];
            
        } else if ( [[video valueForKey:@"provider_name" ] isEqualToString:@"youtube"] ) {
            
            [self setProvider:VideoProvider_YouTube];
            [self loadYouTubePage];
            
        }
        
    }
    
    return self;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
}

#pragma mark - View and Subview Creation Methods
- (UIWebView*)createWebView
{
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(159.0f, 239.0f, 2.0f, 2.0f)];
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
    webView.mediaPlaybackAllowsAirPlay = NO;
    webView.hidden = YES;
    webView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    return webView;
}

- (UIActivityIndicatorView *)createActivityIndicator
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:self.view.frame];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = CGPointMake(self.appDelegate.window.frame.size.width/2.0f, self.appDelegate.window.frame.size.height/2.0f);
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    return indicator;
}

- (void)destroy
{
    [self.moviePlayer.view removeFromSuperview];
    [self dismissModalViewControllerAnimated:YES];
    
}
                      
#pragma mark - Video Playback Methods
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

- (void)playVideo:(NSString *)link
{
    
    if ( ![self videoWillBegin]) {

        self.videoWillBegin = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(destroy)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
        
        [self.indicator stopAnimating];
        [self.indicator removeFromSuperview];
        
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:link]];
        [self.moviePlayer.view setFrame:self.appDelegate.window.frame];
        [self.moviePlayer setFullscreen:YES animated:NO];
        [self.moviePlayer setFullscreen:YES];
        [self.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
        [self.moviePlayer setShouldAutoplay:YES];
        [self.moviePlayer prepareToPlay];
        [self.appDelegate.window addSubview:self.moviePlayer.view];
        [self.moviePlayer play];

    }
}

#pragma mark - Observer Methods
- (void)processNotification:(NSNotification *)notification
{
    
    if ( notification.userInfo && ![notification.userInfo isKindOfClass:[NSNull class]] ) {
        
        NSArray *allValues = [notification.userInfo allValues];
        
        for (NSString *value in allValues) {
            
            SEL pathSelector = @selector(path);
            
            if ([value respondsToSelector:pathSelector]) {
                
                // Remove webView
                [self.webView stopLoading];
                [self.webView removeFromSuperview];
                
                // Get URL
                NSString *path = [value performSelector:pathSelector];
                
                // Launch MPMoviePlayer
                [self playVideo:path];
                
              
            }
        }
        
    }

}

#pragma mark - Interface Orientation Method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

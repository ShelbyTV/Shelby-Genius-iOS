//
//  VideoPlayerContainerViewController.h
//  Shelby-tv
//
//  Created by Arthur Ariel Sabintsev on 7/26/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoPlayerViewController.h"

@interface VideoPlayerContainerViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *videos;
@property (assign, nonatomic) NSUInteger selectedVideo;
@property (copy, nonatomic) NSString *query;
@property (strong, nonatomic) UIWebView *webView;
@property (assign, nonatomic) BOOL controllsModified;

- (id)initWithVideos:(NSMutableArray*)videos selectedVideo:(NSUInteger)selectedVideo andQuery:(NSString*)query;
- (void)videoDidEndPlaying:(NSNotification*)notification;
- (void)previousVideoButtonAction;
- (void)nextVideoButtonAction;
- (void)destroyMoviePlayer;

@end
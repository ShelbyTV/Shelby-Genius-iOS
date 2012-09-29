//
//  VideoPlayerViewController.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/21/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "LoadingVideoView.h"

@class VideoPlayerContainerViewController;

@interface VideoPlayerViewController : MPMoviePlayerViewController 

@property (strong, nonatomic) LoadingVideoView *loadingVideoView;
@property (strong, nonatomic) VideoPlayerContainerViewController *videoPlayerContainerViewController;
@property (strong, nonatomic) NSArray *video;

- (id)initWithVideo:(NSArray*)video andVideoPlayerContainerViewController:(VideoPlayerContainerViewController*)videoPlayerContainerViewController;
- (void)modifyVideoPlayerButtons;
- (void)createLoadingVideoViewForVideo:(NSArray*)video;

@end

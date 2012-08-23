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

@protocol VideoPlayerDelegate <NSObject>
- (void)previousVideoButtonAction;
- (void)nextVideoButtonAction;
@end

@interface VideoPlayerViewController : MPMoviePlayerViewController <VideoPlayerDelegate>

@property (strong, nonatomic) LoadingVideoView *loadingVideoView;

- (id)initWithVideo:(NSArray*)video andVideoPlayerContainerViewController:(VideoPlayerContainerViewController*)videoPlayerContainerViewController;
- (void)modifyVideoPlayerButtons;

@end

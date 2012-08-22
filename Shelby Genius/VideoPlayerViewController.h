//
//  VideoPlayerViewController.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/21/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "LoadingVideoView.h"

@interface VideoPlayerViewController : MPMoviePlayerViewController

@property (strong, nonatomic) LoadingVideoView *loadingVideoView;

- (id)initWithVideo:(NSArray*)video;
- (void)modifyVideoPlayerButtons;
- (void)previousVideoButtonAction;
- (void)nextVideoButtonAction;

@end

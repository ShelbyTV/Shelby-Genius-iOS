//
//  VideoPlayerContainerViewController.h
//  Shelby-tv
//
//  Created by Arthur Ariel Sabintsev on 7/26/12.
//  Copyright (c) 2012 Shelby.tv. All rights reserved.
//

#import "VideoPlayerViewController.h"

@interface VideoPlayerContainerViewController : UIViewController <VideoPlayerDelegate>

@property (strong, nonatomic) NSMutableArray *videos;
@property (assign, nonatomic) NSUInteger selectedVideo;

- (id)initWithVideos:(NSMutableArray*)videos andSelectedVideo:(NSUInteger)selectedVideo;

@end
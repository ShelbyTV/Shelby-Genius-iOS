//
//  LoadingVideoView.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/15/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "LoadingVideoView.h"

@implementation LoadingVideoView
@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize videoTitleLabel = _videoTitleLabel;
@synthesize indicatorView = _indicatorView;
@synthesize loadingLabel = _loadingLabel;

- (void)dealloc
{
    self.thumbnailImageView = nil;
    self.videoTitleLabel = nil;
    self.indicatorView = nil;
    self.loadingLabel = nil;
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.videoTitleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:self.videoTitleLabel.font.pointSize];
    self.loadingLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:self.loadingLabel.font.pointSize];
    
    [self.indicatorView startAnimating];
}

@end

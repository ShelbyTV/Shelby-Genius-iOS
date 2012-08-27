//
//  VideoCardCell.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "VideoCardCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation VideoCardCell
@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize videoTitleLabel = _videoTitleLabel;
@synthesize videoProviderLabel = _videoProviderLabel;
@synthesize shareButton = _shareButton;
@synthesize video = _video;

- (void)dealloc
{
    self.thumbnailImageView = nil;
    self.videoTitleLabel = nil;
    self.videoProviderLabel = nil;
    self.shareButton = nil;
}

- (void)awakeFromNib
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    self.videoTitleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:self.videoTitleLabel.font.pointSize];
    self.videoTitleLabel.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    
    self.videoProviderLabel.font = [UIFont fontWithName:@"Ubuntu" size:self.videoProviderLabel.font.pointSize];
    self.videoProviderLabel.textColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f];
}

@end
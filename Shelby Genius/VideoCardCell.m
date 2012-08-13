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
@synthesize video = _video;

- (void)dealloc
{
    self.thumbnailImageView = nil;
    self.videoTitleLabel = nil;
    self.videoProviderLabel = nil;
}

- (void)awakeFromNib
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
 
    self.videoTitleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:self.videoTitleLabel.font.pointSize];
    
    self.thumbnailImageView.layer.masksToBounds = YES;
    self.thumbnailImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.thumbnailImageView.layer.borderWidth = 1;
}

@end
//
//  VideoCardCell.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "VideoCardCell.h"

@implementation VideoCardCell
@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize videoTitleLabel = _videoTitleLabel;
@synthesize video = _video;

- (void)dealloc
{
    self.thumbnailImageView = nil;
    self.videoTitleLabel = nil;
}

- (void)awakeFromNib
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

@end
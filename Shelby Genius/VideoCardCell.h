//
//  VideoCardCell.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "TopAlignedLabel.h"

@interface VideoCardCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) IBOutlet TopAlignedLabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoProviderLabel;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) NSArray *video;                       

@end
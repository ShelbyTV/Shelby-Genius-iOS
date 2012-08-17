//
//  QueryCell.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "QueryCell.h"

@implementation QueryCell
@synthesize label = _label;

- (void)dealloc
{
    self.label = nil;
}

- (void)awakeFromNib
{
    [self setSelectionStyle:UITableViewCellEditingStyleNone];
    [self setBackgroundColor:[UIColor colorWithRed:226.0f/255.0f green:226.0f/255.0f blue:226.0f/255.0f alpha:1.0f]];
    [self.label setFont:[UIFont fontWithName:@"Ubuntu-Bold" size:self.label.font.pointSize]];
    [self.label setTextColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]];
}

@end

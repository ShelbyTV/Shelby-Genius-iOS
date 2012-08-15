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
    self.label.font = [UIFont fontWithName:@"Ubuntu" size:self.label.font.pointSize];
}

@end

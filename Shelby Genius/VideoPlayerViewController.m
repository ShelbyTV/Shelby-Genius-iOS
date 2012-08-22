//
//  VideoPlayerViewController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/21/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "AsynchronousFreeloader.h"

@interface VideoPlayerViewController ()

@property (strong, nonatomic) NSArray *video;

@end

@implementation VideoPlayerViewController
@synthesize video = _video;
@synthesize loadingVideoView = _loadingVideoView;

- (id)initWithVideo:(NSArray*)video
{
    if (self = [super init] ) {
        
        self.video = video;
            self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    }
    
    return self;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingVideoView" owner:self options:NULL];
    self.loadingVideoView = [nib objectAtIndex:0];
    self.loadingVideoView.videoTitleLabel.text = [NSString stringWithFormat:@"%@", [self.video valueForKey:@"title"]];
    [AsynchronousFreeloader loadImageFromLink:[self.video valueForKey:@"thumbnail_url"] forImageView:self.loadingVideoView.thumbnailImageView withPlaceholderView:nil];
    [self.view addSubview:self.loadingVideoView];
    
    CGRect frame = self.view.bounds;
    [self.loadingVideoView setFrame:CGRectMake(0.0f, 120.0f, frame.size.width, frame.size.height)];
    
}

#pragma mark - Video Button Action Methods
- (void)modifyVideoPlayerButtons
{
    //    NSLog(@"%@", [[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] subviews]);
    
    UIButton *previousVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:1];
    [previousVideoButton addTarget:self action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *nextVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    [nextVideoButton addTarget:self action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)previousVideoButtonAction
{
    NSLog(@"PREVIOUS");
}

- (void)nextVideoButtonAction
{
    NSLog(@"NEXT");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if (self.loadingVideoView) {
     
        CGRect frame = self.view.bounds;
        
        if ( interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
            
            [self.loadingVideoView setFrame:CGRectMake(0.0f, 120.0f, frame.size.width, frame.size.height)];
            
        } else {
            
            if (self.loadingVideoView) [self.loadingVideoView setFrame:CGRectMake(100.0f, 30.0f, frame.size.height, frame.size.width)];
            
        }
        
    }
    
    return interfaceOrientation;
}

@end

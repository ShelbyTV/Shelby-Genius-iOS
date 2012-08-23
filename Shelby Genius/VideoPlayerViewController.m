//
//  VideoPlayerViewController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/21/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "VideoPlayerContainerViewController.h"
#import "AsynchronousFreeloader.h"

@interface VideoPlayerViewController ()

@property (strong, nonatomic) NSArray *video;
@property (strong, nonatomic) VideoPlayerContainerViewController *videoPlayerContainerViewController;

@end

@implementation VideoPlayerViewController
@synthesize video = _video;
@synthesize videoPlayerContainerViewController = _videoPlayerContainerViewController;
@synthesize loadingVideoView = _loadingVideoView;

- (id)initWithVideo:(NSArray *)video andVideoPlayerContainerViewController:(VideoPlayerContainerViewController *)videoPlayerContainerViewController
{
    if (self = [super init] ) {
        
        self.videoPlayerContainerViewController = videoPlayerContainerViewController;
        self.video = video;

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

#pragma mark - Public Methods
- (void)modifyVideoPlayerButtons
{
    // Done Button
//    UIButton *doneButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:2] subviews] objectAtIndex:3];
//    [doneButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [doneButton addTarget:self.videoPlayerContainerViewController action:@selector(destroy:) forControlEvents:UIControlEventTouchUpInside];
    
    // Video Player Controls
    UIButton *previousVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:1];
    [previousVideoButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [previousVideoButton addTarget:self action:@selector(previousVideoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *nextVideoButton = [[[[[[[[[self.moviePlayer.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews] objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    [nextVideoButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [nextVideoButton addTarget:self action:@selector(nextVideoButtonAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Private Methods
- (void)previousVideoButtonAction
{
    [self.videoPlayerContainerViewController previousVideoButtonAction];
}

- (void)nextVideoButtonAction
{
    [self.videoPlayerContainerViewController nextVideoButtonAction];
}

#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if (self.loadingVideoView) {
     
        CGRect frame = self.view.bounds;
        
        if ( interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
            
            [self.loadingVideoView setFrame:CGRectMake(0.0f, 120.0f, frame.size.width, frame.size.height)];
            [self.loadingVideoView.videoTitleLabel setHidden:NO];
            
        } else {
            
            [self.loadingVideoView setFrame:CGRectMake(80.0f, 60.0f, frame.size.height, frame.size.width)];
            [self.loadingVideoView.videoTitleLabel setHidden:YES];
        }
        
    }
    
    return interfaceOrientation;
}

@end

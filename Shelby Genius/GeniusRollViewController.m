//
//  GeniusRollViewController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "GeniusRollViewController.h"

// Frameworks
#import "AsynchronousFreeloader.h"

// Models
#import "AppDelegate.h"

// Views
#import "VideoCardCell.h"

// Controllers
#import "APIClient.h"
#import "SocialController.h"

// View Controllers
#import "VideoPlayerContainerViewController.h"

@interface GeniusRollViewController () 

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableArray *resultsArray;
@property (strong, nonatomic) NSArray *selectedVideoFrameToShare;
@property (assign, nonatomic) NSUInteger numberOfFetchedResults;
@property (assign, nonatomic) BOOL isFetchingMoreVideos;
@property (assign, nonatomic) BOOL isPlayingVideo;
@property (assign, nonatomic) BOOL noMoreVideosToFetch;

- (void)customize;
- (void)initalizeObservers;
- (void)search;
- (void)refreshDataSource;
- (void)shareVideoAction:(UIButton *)button;
- (void)makeResultsArray:(NSNotification *)notification;
- (void)scrollToCurrentVideo:(NSNotification*)notification;

@end

@implementation GeniusRollViewController
@synthesize tableView = _tableView;
@synthesize appDelegate = _appDelegate;
@synthesize resultsArray = _resultsArray;
@synthesize query = _query;
@synthesize selectedVideoFrameToShare = _selectedVideoFrameToShare;
@synthesize numberOfFetchedResults = _numberOfFetchedResults;
@synthesize isFetchingMoreVideos = _isFetchingMoreVideos;
@synthesize isPlayingVideo = _isPlayingVideo;
@synthesize noMoreVideosToFetch = _noMoreVideosToFetch;

#pragma mark - Initialization
- (id)initWithQuery:(NSString *)query
{
    if ( self = [super init] ) {

        self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.query = query;

        
    }
    
    return self;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidUnload
{
    NSString *querySpecificObserver = [NSString stringWithFormat:@"%@_%@", kRollFramesObserver, self.query];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:querySpecificObserver object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kIndexOfCurrentVideoObserver object:nil];
    
    self.tableView = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customize];
    [self search];
    [self initalizeObservers];

}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    // Annoying iOS5 status bar color fix
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    // Annoying iOS6 orientation fix when GenisuRollViewController is Re-Presented
    if ( 6 == kSystemVersion ) { /// iOS 6 is installed
        
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        UIViewController *mVC = [[UIViewController alloc] init];
        [self presentViewController:mVC animated:NO completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
        
    }

    
    if ( [self isPlayingVideo] ) {
        
        [self setIsPlayingVideo:NO];
        CGRect frame = self.view.frame;
        self.view.frame = CGRectMake(frame.origin.x,
                                     20.0f + frame.origin.y,
                                     frame.size.width,
                                     frame.size.height);
        
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.appDelegate removeHUD];
}

#pragma mark - Private Methods
- (void)customize
{
    // General Customization
    self.title = @"Genius Results";
    self.view.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    
    // Custom Back-UIBarButtonItem
    UIButton *backBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 52, 32)];
    [backBarButton setImage:[UIImage imageNamed:@"navigationBackButton"] forState:UIControlStateNormal];
    [backBarButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBarButton];
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
}

- (void)initalizeObservers
{
    NSString *querySpecificObserver = [NSString stringWithFormat:@"%@_%@", kRollFramesObserver, self.query];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeResultsArray:)
                                                 name:querySpecificObserver
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollToCurrentVideo:)
                                                 name:kIndexOfCurrentVideoObserver
                                               object:nil];
    
}

- (void)search
{
    self.query = [self.query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    APIClient *client = [[APIClient alloc] init];
    NSString *requestString = [NSString stringWithFormat:kGetQuery, self.query];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [client performRequest:request ofType:APIRequestType_GetQuery withQuery:self.query];
    
    
    [self.appDelegate addHUDWithMessage:@"Fetching Genius Videos"];
    
}

- (void)makeResultsArray:(NSNotification *)notification
{
    

    if ( ![self resultsArray] ) { // If array DOES NOT exists (e.g., these are the results of the first API call)
        
        if ( 0 == [[[notification.userInfo objectForKey:@"result"] valueForKey:@"frames"] count] ) {         // If no results are returned
            
            [self.appDelegate removeHUD];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNoResultsReturnedObserver object:nil];

        } else { // If results are returned
        
            [[Panhandler sharedInstance] recordEvent];
            
            self.resultsArray = [NSMutableArray array];
            [self.resultsArray addObjectsFromArray:[[notification.userInfo objectForKey:@"result"] valueForKey:@"frames"]];
            self.numberOfFetchedResults = [self.resultsArray count];
            self.noMoreVideosToFetch = NO;
            
            /// Check for videos with <null> values, and remove them from the resultsArray
            // 1. Create duplicate of resultsArray
            NSArray *duplicateResultsArray = [NSArray arrayWithArray:self.resultsArray];
            
            // 2. Search duplicateResultsArray for frames
            for (NSArray *frameArray in duplicateResultsArray) {
                
                NSString *thumbnailURL = [[frameArray valueForKey:@"video"] valueForKey:@"thumbnail_url"];
                NSString *videoTitle = [[frameArray valueForKey:@"video"] valueForKey:@"title"];
                NSString *providerName = [[frameArray valueForKey:@"video"] valueForKey:@"provider_name"];

                // 3. Check for <null>-values frames
                if ( thumbnailURL == (id)[NSNull null] || videoTitle == (id)[NSNull null] || providerName == (id)[NSNull null] ) {
                    
                    // Remove frameArray object found in duplicateResultsArray from resultsArray
                    [self.resultsArray removeObject:frameArray];
                }
                
            }
            
            // Reset values and reload tableView
            [self setIsFetchingMoreVideos:NO];
            [self setNoMoreVideosToFetch:NO];
            [self.appDelegate removeHUD];
            [self.tableView reloadData];
        
        }
        
    } else { // If array DOES exists (e.g., these are the results of a subsequent API call)
        
        [self.resultsArray addObjectsFromArray:[[notification.userInfo objectForKey:@"result"] valueForKey:@"frames"]];
        
        if ( [self.resultsArray count] <= self.numberOfFetchedResults) {
            
            // Reset values
            [self setIsFetchingMoreVideos:NO];
            [self setNoMoreVideosToFetch:YES];
            [self.appDelegate removeHUD];
                
        } else {
        
            [[Panhandler sharedInstance] recordEvent];
            
            self.numberOfFetchedResults = self.numberOfFetchedResults + [[[notification.userInfo objectForKey:@"result"] valueForKey:@"frames"] count];
           
            /// Check for videos with <null> values, and remove them from the resultsArray
            // 1. Create duplicate of resultsArray
            NSArray *duplicateResultsArray = [NSArray arrayWithArray:self.resultsArray];
            
            // 2. Search duplicateResultsArray for frames
            for (NSArray *frameArray in duplicateResultsArray) {
                
                NSString *thumbnailURL = [[frameArray valueForKey:@"video"] valueForKey:@"thumbnail_url"];
                NSString *videoTitle = [[frameArray valueForKey:@"video"] valueForKey:@"title"];
                NSString *providerName = [[frameArray valueForKey:@"video"] valueForKey:@"provider_name"];
                
                // 3. Check for <null>-values frames
                if ( thumbnailURL == (id)[NSNull null] || videoTitle == (id)[NSNull null] || providerName == (id)[NSNull null] ) {
                    
                    // Remove frameArray object found in duplicateResultsArray from resultsArray
                    [self.resultsArray removeObject:frameArray];
                }
                
            }
            
            // Reset values and reload tableView
            [self setIsFetchingMoreVideos:NO];
            [self setNoMoreVideosToFetch:NO];
            [self.appDelegate removeHUD];
            [self.tableView reloadData];

        }
   
    }
    
}

- (void)refreshDataSource
{
    /*
     
     Conditions Explained
     
     1: self.numberOfFetchedResults > kMinimumVideoCountBeforeFetch
     There must be at least 20 results before trying to fetch more results (20 is the minimum 1 API 
     call returns - why make subsequent API calls if less than 20 are returned the first time?)

     2. NO == self.isFetchingMoreVideos
     Avoid subsquent re-fetches when a fetch is in progress
     
     3. NO == self.noMoreVideosToFetch
     Avoid fetching movies if the previous fetch didn't return any new movies.
     
     --- 
     
     NOTE: Call this method to fetch videos when ONLY the third-to-last video has displayed to the screen, 
     so that when the user gets to the last video, the other ones will have loaded or are about to be loaded.
     
     
     */
    
    if ( (self.numberOfFetchedResults >= kMinimumVideoCountBeforeFetch) && (NO == self.isFetchingMoreVideos) && (NO == self.noMoreVideosToFetch) ) {
        
        NSString *rollID = [[NSUserDefaults standardUserDefaults] objectForKey:kRollID];
        NSString *requestString = [NSString stringWithFormat:kGetRollFramesAgain, rollID, self.numberOfFetchedResults];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
        APIClient *client = [[APIClient alloc] init];
        [client performRequest:request ofType:APIRequestType_GetRollFrames withQuery:self.query];
        
        if ( self == self.navigationController.visibleViewController ) [self.appDelegate addHUDWithMessage:@"Getting more Genius videos"];
        [self setIsFetchingMoreVideos:YES];
        [self setNoMoreVideosToFetch:YES];
        
    }
}

- (void)shareVideoAction:(UIButton *)button
{
    VideoCardCell *cell = (VideoCardCell*)[button superview];
    self.selectedVideoFrameToShare = cell.videoFrame;
    
    if ( 6 == kSystemVersion ) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share this video?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil];
        
        [actionSheet showInView:self.tableView];
        
    } else {
        
    
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share this video?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Email", @"Twitter", nil];
        
        [actionSheet showInView:self.tableView];
        
    }
    
    
}

- (void)scrollToCurrentVideo:(NSNotification*)notification
{
    NSNumber *row = [notification.userInfo objectForKey:kIndexOfCurrentVideo];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[row intValue] inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    
    if ( [row intValue] >= [self.resultsArray count]-3 ) [self refreshDataSource];
    
}

- (void)scrollToLastCell
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.resultsArray count]-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}

#pragma mark - UIActionSheetDelegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ( 6 == kSystemVersion ) {
        
        switch (buttonIndex) {
            case 0: // Email
                [[SocialController sharedInstance] shareVideo:self.selectedVideoFrameToShare toChannel:SocialShare_Email inViewController:self];
                break;
            case 1: // Twitter
                [[SocialController sharedInstance] shareVideo:self.selectedVideoFrameToShare toChannel:SocialShare_Twitter inViewController:self];
                break;
            case 2: // Twitter
                [[SocialController sharedInstance] shareVideo:self.selectedVideoFrameToShare toChannel:SocialShare_Facebook inViewController:self];
                break;
            default:
                break;
        }
        
        
    } else {
        
        switch (buttonIndex) {
            case 0: // Email
                [[SocialController sharedInstance] shareVideo:self.selectedVideoFrameToShare toChannel:SocialShare_Email inViewController:self];
                break;
            case 1: // Twitter
                [[SocialController sharedInstance] shareVideo:self.selectedVideoFrameToShare toChannel:SocialShare_Twitter inViewController:self];
                break;
            default:
                break;
        }
        
    }


}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( [self.resultsArray count] ) {
        
        tableView.alpha = 1.0f;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoCardCell_iphone" owner:self options:nil];
        VideoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCardCell"];
        
        if ( nil == cell ) cell = (VideoCardCell*)[nib objectAtIndex:0];

        NSString *thumbnailURL = [[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"thumbnail_url"];
        NSString *videoTitle = [[[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"title"] capitalizedString];
        NSString *providerName = [[[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"provider_name"] capitalizedString];

        [AsynchronousFreeloader loadImageFromLink:thumbnailURL forImageView:cell.thumbnailImageView withPlaceholderView:nil];
        cell.videoTitleLabel.text = videoTitle;
        cell.videoProviderLabel.text = providerName;
        cell.videoFrame = [self.resultsArray objectAtIndex:indexPath.row];
        [cell.shareButton addTarget:self action:@selector(shareVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.invisibleShareButton addTarget:self action:@selector(shareVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier: @"Cell"];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
        
    }
    
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = [self.resultsArray count];
    return (rows) ? rows : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self.resultsArray count]) ? 72.0f : 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 27.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Create frame of UITableView Section Header
    CGRect tableSectionHeaderFrame = CGRectMake(0.0f,
                                                0.0f,
                                                tableView.bounds.size.width,
                                                tableView.sectionHeaderHeight);
    
    // Create view for UITableView section header
    UIView *view = [[UIView alloc] initWithFrame:tableSectionHeaderFrame];
    view.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    
    // Border on the bottom of the section header
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  4.0f+tableView.sectionHeaderHeight,
                                                                  tableView.bounds.size.width,
                                                                  1.0f)];
    borderView.backgroundColor = [UIColor colorWithRed:173.0f/255.0f green:173.0f/255.0f blue:173.0f/255.0f alpha:1.0f];
    [view addSubview:borderView];
    
    // Section header label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f + tableSectionHeaderFrame.origin.x,
                                                               4.0f + tableSectionHeaderFrame.origin.y,
                                                               -10.0f + tableSectionHeaderFrame.size.width,
                                                               -2.0f + tableSectionHeaderFrame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Ubuntu-Medium" size:14];
    label.text = [NSString stringWithFormat:@"“%@”", [self.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    label.text = [label.text stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    if ( 6 == kSystemVersion ) {
        
        label.textAlignment = NSTextAlignmentLeft;
        
    } else {
        
        label.textAlignment = UITextAlignmentLeft;
    
    }
    

    label.textColor = [UIColor blackColor];
    [view addSubview:label];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( kDeviceIsIPad ) {
    
        VideoPlayerContainerViewController *videoPlayerContainerViewController = [[VideoPlayerContainerViewController alloc] initWithVideos:self.resultsArray selectedVideo:indexPath.row andQuery:self.query];
        [self.appDelegate.detailNavigationController pushViewController:videoPlayerContainerViewController animated:NO];
        
        [self setIsPlayingVideo:YES];
        
    } else {
    
        VideoPlayerContainerViewController *videoPlayerContainerViewController = [[VideoPlayerContainerViewController alloc] initWithVideos:self.resultsArray selectedVideo:indexPath.row andQuery:self.query];
        [self.navigationController pushViewController:videoPlayerContainerViewController animated:YES];
        
        [self setIsPlayingVideo:YES];
        
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row == [self.resultsArray count]-3 ) [self refreshDataSource];
}

#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning
{
    [AsynchronousFreeloader removeAllImages];
}

#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
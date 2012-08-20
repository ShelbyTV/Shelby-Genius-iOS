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
#import "VideoPlayerViewController.h"

@interface GeniusRollViewController ()

@property (strong, nonatomic) NSMutableArray *resultsArray;
@property (strong, nonatomic) NSString *query;
@property (assign, nonatomic) BOOL isFetchingMoreVideos;
@property (assign, nonatomic) BOOL isPlayingVideo;

- (void)customize;
- (void)initalizeObservers;
- (void)search;
- (void)makeResultsArray:(NSNotification *)notification;

@end

@implementation GeniusRollViewController
@synthesize tableView = _tableView;
@synthesize resultsArray = _resultsArray;
@synthesize query = _query;
@synthesize isFetchingMoreVideos = _isFetchingMoreVideos;
@synthesize isPlayingVideo = _isPlayingVideo;

#pragma mark - Initialization
- (id)initWithQuery:(NSString *)query
{
    if ( self = [super init] ) {

        self.query = query;
        [self search];
        
    }
    
    return self;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidUnload
{
    NSString *querySpecificObserver = [NSString stringWithFormat:@"%@_%@", kRollFramesObserver, self.query];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:querySpecificObserver object:nil];
   
    self.tableView = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customize];
    [self initalizeObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( [self isPlayingVideo] ) {
        
        [self setIsPlayingVideo:NO];
        CGRect frame = self.view.frame;
        self.view.frame = CGRectMake(frame.origin.x,
                                     20.0f + frame.origin.y,
                                     frame.size.width,
                                     frame.size.height);
        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate removeHUD];
}

#pragma mark - Private Methods
- (void)customize
{
    self.title = @"Genius Results";
    self.view.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
}

- (void)initalizeObservers
{
    NSString *querySpecificObserver = [NSString stringWithFormat:@"%@_%@", kRollFramesObserver, self.query];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeResultsArray:)
                                                 name:querySpecificObserver
                                               object:nil];
}

- (void)search
{
    self.query = [self.query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    APIClient *client = [[APIClient alloc] init];
    NSString *requestString = [NSString stringWithFormat:kGetQuery, self.query];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    [client performRequest:request ofType:APIRequestType_GetQuery withQuery:self.query];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate addHUDWithMessage:@"Fetching Genius Videos"];
    
}

- (void)makeResultsArray:(NSNotification *)notification
{
    if ( ![self resultsArray] ) {
        
        self.resultsArray = [NSMutableArray array];
        [self.resultsArray addObjectsFromArray:[[notification.userInfo objectForKey:@"result"] valueForKey:@"frames"]];
        
        [[Panhandler sharedInstance] recordEvent];
        
    } else {
        
        [self.resultsArray addObjectsFromArray:[[notification.userInfo objectForKey:@"result"] valueForKey:@"frames"]];
        
    }
    
    [self setIsFetchingMoreVideos:NO];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate removeHUD];
    [self.tableView reloadData];
    
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
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoCardCell" owner:self options:nil];
        VideoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCardCell"];
        if ( nil == cell ) cell = (VideoCardCell*)[nib objectAtIndex:0];
        
        NSString *thumbnailURL = [[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"thumbnail_url"];
        NSString *videoTitle = [[[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"title"] capitalizedString];
        NSString *providerName = [[[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"provider_name"] capitalizedString];

        
        if (thumbnailURL != (id)[NSNull null]) [AsynchronousFreeloader loadImageFromLink:thumbnailURL forImageView:cell.thumbnailImageView withPlaceholderView:nil];
        if (videoTitle != (id)[NSNull null]) cell.videoTitleLabel.text = videoTitle;
        if (videoTitle != (id)[NSNull null]) cell.videoProviderLabel.text = providerName;
        cell.video = [[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"];
        
        return cell;
        
    } else {
        
        tableView.alpha = 0.0f;
        return [[UITableViewCell alloc] initWithStyle:UITableViewStyleGrouped reuseIdentifier: @"Cell"];;
        
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
    return ([self.resultsArray count]) ? 27.0f : 0.0f;
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
    label.text = [NSString stringWithFormat:@"\"%@\"", [self.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    label.text = [label.text stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    label.textAlignment = UITextAlignmentLeft;
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
    VideoCardCell *cell = (VideoCardCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    VideoPlayerViewController *videoPlayerViewController = [[VideoPlayerViewController alloc] initWithVideo:cell.video];
    [self.navigationController pushViewController:videoPlayerViewController animated:YES];
    
    [self setIsPlayingVideo:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( ([self.resultsArray count] > kMinimumVideoCountBeforeFetch) && (indexPath.row == [self.resultsArray count]-3) && (NO == self.isFetchingMoreVideos) ) {
        
        NSString *rollID = [[NSUserDefaults standardUserDefaults] objectForKey:kRollID];
        NSString *requestString = [NSString stringWithFormat:kGetRollFramesAgain, rollID, [self.resultsArray count]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
        APIClient *client = [[APIClient alloc] init];
        [client performRequest:request ofType:APIRequestType_GetRollFrames withQuery:self.query];
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate addHUDWithMessage:@"Getting more Genius videos"];
        
        [self setIsFetchingMoreVideos:YES];
        
    }
}

#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning
{
    [AsynchronousFreeloader removeAllImages];
}

#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end

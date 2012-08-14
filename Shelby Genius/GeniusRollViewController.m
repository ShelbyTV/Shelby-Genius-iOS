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

#pragma mark - Initialization
- (id)initWithQuery:(NSString *)query
{
    if ( self = [super init] ) {
        
        self.query = query;
        [self search];
        self.title = query;
        
    }
    
    return self;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRollFramesObserver object:nil];
   
    self.tableView = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customize];
    [self initalizeObservers];
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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSectionHeaderBackground"]];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSectionHeaderBackground"]];
    self.tableView.separatorColor = [UIColor blackColor];
}

- (void)initalizeObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeResultsArray:)
                                                 name:kRollFramesObserver
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Create frame of UITableView Section Header
    CGRect tableSectionHeaderFrame = CGRectMake(0.0f,
                                                0.0f,
                                                tableView.bounds.size.width,
                                                tableView.sectionHeaderHeight);
    
    // Create view for UITableView Section Header
    UIView *view = [[UIView alloc] initWithFrame:tableSectionHeaderFrame];
    
    // Background (issue with RGB-UIColor)
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableSectionHeaderBackground"]];
    [view addSubview:backgroundView];
    
    // 1px border on the bottom of the cell
    UIView *strokeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  -1.0f + tableView.sectionFooterHeight,
                                                                  tableView.bounds.size.width,
                                                                  1.0f)];
    strokeView.backgroundColor = [UIColor blackColor];
    [view addSubview:strokeView];
    
    // Section Header Label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f + tableSectionHeaderFrame.origin.x,
                                                               2.0f + tableSectionHeaderFrame.origin.y,
                                                               -10.0f + tableSectionHeaderFrame.size.width,
                                                               -2.0f + tableSectionHeaderFrame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Ubuntu-Bold" size:11];
    label.text = [NSString stringWithFormat:@"Genius results for %@", self.query];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = [self.resultsArray count];
    return (rows) ? rows : 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self.resultsArray count]) ? 94.0f : 44.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( [self.resultsArray count] ) {
        
        tableView.alpha = 1.0f;
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoCardCell" owner:self options:nil];
        VideoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCardCell"];
        if ( nil == cell ) cell = (VideoCardCell*)[nib objectAtIndex:0];
        
        NSString *thumbnailURL = [[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"thumbnail_url"];
        NSString *videoTitle = [[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"title"];
        NSString *providerName = [[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"provider_name"];

        
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCardCell *cell = (VideoCardCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    VideoPlayerViewController *videoPlayerViewController = [[VideoPlayerViewController alloc] initWithVideo:cell.video];
    [videoPlayerViewController shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight];
    [self presentModalViewController:videoPlayerViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( ([self.resultsArray count] > kMinimumVideoCountBeforeFetch) && (indexPath.row == [self.resultsArray count]-2) && (NO == self.isFetchingMoreVideos) ) {
        
        NSString *rollID = [[NSUserDefaults standardUserDefaults] objectForKey:kRollID];
        NSString *requestString = [NSString stringWithFormat:kGetRollFramesAgain, rollID, [self.resultsArray count]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
        APIClient *client = [[APIClient alloc] init];
        [client performRequest:request ofType:APIRequestType_GetRollFrames withQuery:nil];
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate addHUDWithMessage:@"Getting more 'Genius' Videos"];
        
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

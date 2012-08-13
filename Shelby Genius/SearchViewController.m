//
//  ViewController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "SearchViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "VideoCardCell.h"
#import "AsynchronousFreeloader.h"
#import "VideoPlayerViewController.h"

@interface SearchViewController ()

@property (strong, nonatomic) NSMutableArray *resultsArray;

- (void)makeResultsArray:(NSNotification*)notification;
- (void)search;

@end

@implementation SearchViewController
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize resultsArray = _resultsArray;

#pragma mark - View Lifecycle Methods
- (void)viewDidUnload
{
    self.tableView = nil;
    self.searchBar = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:226.0f green:226.0f blue:226.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.searchBar.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeResultsArray:)
                                                 name:kRollFramesObserver
                                               object:nil];
}

#pragma mark - Action Methods
- (void)search
{

    // Hide keyboard
    if ( [self.searchBar isFirstResponder] ) {
        [self.searchBar resignFirstResponder];
    }
    
    if ( self.resultsArray ) {
        
        [self.resultsArray removeAllObjects];
        [self.tableView reloadData];
    }
    
    if ( self.searchBar.text.length ) {

        NSString *query = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        APIClient *client = [[APIClient alloc] init];
        NSString *requestString = [NSString stringWithFormat:kGetQuery, query];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
        
        [client performRequest:request ofType:APIRequestType_GetQuery withQuery:query];
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate addHUDWithMessage:@"Fetching 'Genius' Videos"];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You must type in a query"
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil, nil];
        
        [alert show];
        
    }
    
}

#pragma mark - Observer Methods
- (void)makeResultsArray:(NSNotification *)notification
{
    if ( ![self resultsArray] ) {
        
        self.resultsArray = [NSMutableArray array];
        [self.resultsArray addObjectsFromArray:[[notification.userInfo objectForKey:@"result"] valueForKey:@"frames"]];
        
    } else {
     
        [self.resultsArray addObjectsFromArray:[[notification.userInfo objectForKey:@"result"] valueForKey:@"frames"]];
        
    }
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate removeHUD];
    [self.tableView reloadData];

}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search];
}



#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSString *title = @"";

    if (0 == section) {
        
        self.title = @"Previous Shelby Searches";
        
    }
    
    return title;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect tableSectionHeaderFrame = CGRectMake(0.0f, 0.0f, 320.0f, tableView.sectionHeaderHeight);
    UIView *view = [[UIView alloc] initWithFrame:tableSectionHeaderFrame];
    view.backgroundColor = [UIColor colorWithRed:238.0f green:238.0f blue:238.0f alpha:1.0f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f + tableSectionHeaderFrame.origin.x,
                                                               2.0f + tableSectionHeaderFrame.origin.y,
                                                               -10.0f + tableSectionHeaderFrame.size.width,
                                                               -2.0f + tableSectionHeaderFrame.size.height)];
    
    NSLog(@"%@", NSStringFromCGRect(tableSectionHeaderFrame));
    
    label.text = @"Previous Shelby Searches";
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"Ubuntu-Bold" size:13];
    
    [view addSubview:label];
    
    return view;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = [self.resultsArray count];
    return (rows) ? rows : 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self.resultsArray count]) ? 140.0f : 44.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ( [self.resultsArray count] ) {
    
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoCardCell" owner:self options:nil];
        VideoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCardCell"];
        if ( nil == cell ) cell = (VideoCardCell*)[nib objectAtIndex:0];
        
        NSLog(@"%@", [self.resultsArray objectAtIndex:indexPath.row]);
        
        NSString *thumbnailURL = [[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"thumbnail_url"];
        NSString *videoTitle = [[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"title"];
        
        if (thumbnailURL != (id)[NSNull null]) [AsynchronousFreeloader loadImageFromLink:thumbnailURL forImageView:cell.thumbnailImageView withPlaceholderView:nil];
        if (videoTitle != (id)[NSNull null]) cell.videoTitleLabel.text = videoTitle;
        cell.video = [[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"];
        
        return cell;
        
    } else {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewStyleGrouped reuseIdentifier: @"Cell"];
        cell.textLabel.text = @"Type something sexy in the field above";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    
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
    if ([self.resultsArray count] > 19 && indexPath.row == [self.resultsArray count]-2) {
        
        NSString *rollID = [[NSUserDefaults standardUserDefaults] objectForKey:kRollID];
        NSString *requestString = [NSString stringWithFormat:kGetRollFramesAgain, rollID, [self.resultsArray count]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
        APIClient *client = [[APIClient alloc] init];
        [client performRequest:request ofType:APIRequestType_GetRollFrames withQuery:nil];
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate addHUDWithMessage:@"Getting more 'Genius' Videos"];
        
    }
}

#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end

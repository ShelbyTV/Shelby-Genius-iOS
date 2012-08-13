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

@end

@implementation GeniusRollViewController
@synthesize resultsArray = _resultsArray;

#pragma mark - View Lifecycle Methods
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeResultsArray:)
                                                 name:kRollFramesObserver
                                               object:nil];
    
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

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect tableSectionHeaderFrame = CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, tableView.sectionHeaderHeight);
    UIView *view = [[UIView alloc] initWithFrame:tableSectionHeaderFrame];
    view.backgroundColor = [UIColor colorWithRed:238.0f green:238.0f blue:238.0f alpha:1.0f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f + tableSectionHeaderFrame.origin.x,
                                                               1.0f + tableSectionHeaderFrame.origin.y,
                                                               -10.0f + tableSectionHeaderFrame.size.width,
                                                               -1.0f + tableSectionHeaderFrame.size.height)];
    
    label.backgroundColor = [UIColor clearColor];
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
    if ([self.resultsArray count] > kMinimumVideoCountBeforeFetch && indexPath.row == [self.resultsArray count]-2) {
        
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
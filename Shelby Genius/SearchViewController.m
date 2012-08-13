//
//  ViewController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "SearchViewController.h"

// Models
#import "AppDelegate.h"

// Views
#import "QueryCell.h"

// Controllers
#import "APIClient.h"
#import "GeniusRollViewController.h"

@interface SearchViewController ()

@property (strong, nonatomic) NSMutableArray *previousQueriesArray;

- (void)customize;
- (void)search;

@end

@implementation SearchViewController
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize previousQueriesArray = _previousQueriesArray;

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
    [self customize];

}

#pragma mark - Private Methods
- (void)customize
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSectionHeaderBackground"]];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSectionHeaderBackground"]];
    self.tableView.separatorColor = [UIColor blackColor];
}

- (void)search
{

    // Hide keyboard
    if ( [self.searchBar isFirstResponder] ) {
        [self.searchBar resignFirstResponder];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect tableSectionHeaderFrame = CGRectMake(0.0f,
                                                0.0f,
                                                tableView.bounds.size.width,
                                                tableView.sectionHeaderHeight);
    
    UIView *view = [[UIView alloc] initWithFrame:tableSectionHeaderFrame];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableSectionHeaderBackground"]];
    [view addSubview:backgroundView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f + tableSectionHeaderFrame.origin.x,
                                                               2.0f + tableSectionHeaderFrame.origin.y,
                                                               -10.0f + tableSectionHeaderFrame.size.width,
                                                               -2.0f + tableSectionHeaderFrame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Ubuntu-Bold" size:13];
    label.text = @"Previous Shelby Searches";
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor blackColor];

    [view addSubview:label];
    
    return view;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = [self.previousQueriesArray count];
    return (rows) ? rows : 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QueryCell" owner:self options:nil];
    QueryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueryCell"];
    if ( nil == cell ) cell = (QueryCell*)[nib objectAtIndex:0];
    
    cell.label.text = @"Test Search";

    return cell;

}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Push instance of GeniusRollViewController
}

#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end

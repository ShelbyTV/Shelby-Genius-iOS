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
- (void)initializePreviousQueriesArray;
- (void)modifyPreviousQueriesArray;
- (void)createGeniusRoll;

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
    [self initializePreviousQueriesArray];

}

#pragma mark - Private Methods
- (void)customize
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"queryCellBackground"]];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSectionHeaderBackground"]];
    self.tableView.separatorColor = [UIColor blackColor];
}

- (void)initializePreviousQueriesArray
{
    
    NSMutableArray *testArray = [[NSUserDefaults standardUserDefaults] objectForKey:kPreviousQueries];
    if ( [testArray count] ) {
        
        self.previousQueriesArray = [NSMutableArray arrayWithArray:testArray];
        
    } else {
    
        self.previousQueriesArray = [NSMutableArray array];
        
    }
    
}

- (void)modifyPreviousQueriesArray
{
    
    if (self.searchBar.text.length) {
            
        NSArray *reversedArray = [[self.previousQueriesArray reverseObjectEnumerator] allObjects];
        [self.previousQueriesArray removeAllObjects];
        [self.previousQueriesArray addObjectsFromArray:reversedArray];
        [self.previousQueriesArray addObject:self.searchBar.text];
        NSArray *secondReversedArray = [[self.previousQueriesArray reverseObjectEnumerator] allObjects];
        [self.previousQueriesArray removeAllObjects];
        [self.previousQueriesArray addObjectsFromArray:secondReversedArray];
        
        if ( [self.previousQueriesArray count] > 10) [self.previousQueriesArray removeLastObject];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.previousQueriesArray forKey:kPreviousQueries];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.tableView reloadData];
  
    }
    
}

- (void)createGeniusRoll
{
    GeniusRollViewController *geniusRollViewController = [[GeniusRollViewController alloc] initWithQuery:self.searchBar.text];
    [self.navigationController pushViewController:geniusRollViewController animated:YES];
}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Hide keyboard
    if ( [self.searchBar isFirstResponder] ) {
        [self.searchBar resignFirstResponder];
    }
        
    [self modifyPreviousQueriesArray];
    [self createGeniusRoll];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([self.previousQueriesArray count]) ? 22.0f : 0.0f;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.previousQueriesArray count] ) {
        
        tableView.alpha = 1.0f;
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QueryCell" owner:self options:nil];
        QueryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueryCell"];
        if ( nil == cell ) cell = (QueryCell*)[nib objectAtIndex:0];
        
        cell.label.text = [self.previousQueriesArray objectAtIndex:indexPath.row];
        
        return cell;
        
    } else {

        tableView.alpha = 0.0f;
        
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];;
    }

}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueryCell *cell = (QueryCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    GeniusRollViewController *geniusRollViewController = [[GeniusRollViewController alloc] initWithQuery:cell.label.text];
    [self.navigationController pushViewController:geniusRollViewController animated:YES];
}

#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
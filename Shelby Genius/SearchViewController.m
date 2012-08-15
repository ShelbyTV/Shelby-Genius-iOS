//
//  SearchViewController.m
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
@property (strong, nonatomic) UIView *transparentTouchableView;
@property (strong, nonatomic) UIView *transparentTouchableNavigationView;

- (void)customize;
- (void)createTransparentTouchableViews;
- (void)initializePreviousQueriesArray;
- (void)modifyPreviousQueriesArray;
- (void)savePreviousQueriesArray;
- (void)createGeniusRoll;
- (void)removeTransparentViews;

@end

@implementation SearchViewController
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize previousQueriesArray = _previousQueriesArray;
@synthesize transparentTouchableView = _transparentTouchableView;
@synthesize transparentTouchableNavigationView = _transparentTouchableNavigationView;

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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeTransparentViews];
}

#pragma mark - Private Methods
- (void)customize
{
    // Root View
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"queryCellBackground"]];
    
    // Table View
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableSectionHeaderBackground"]];
    self.tableView.scrollEnabled = NO;
    
}

- (void)createTransparentTouchableViews
{
    
    self.transparentTouchableView = [[UIView alloc] initWithFrame:self.tableView.frame];
    self.transparentTouchableView.backgroundColor = [UIColor clearColor];
    self.transparentTouchableView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tableTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeTransparentViews)];
    tableTapGesture.numberOfTapsRequired = 1;
    [self.transparentTouchableView addGestureRecognizer:tableTapGesture];
    [self.tableView addSubview:self.transparentTouchableView];
    
    self.transparentTouchableNavigationView = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.frame];
    self.transparentTouchableNavigationView.backgroundColor = [UIColor clearColor];
    self.transparentTouchableNavigationView.userInteractionEnabled = YES;
    [self.navigationController.navigationBar addSubview:self.transparentTouchableNavigationView];
    UITapGestureRecognizer *navigationTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeTransparentViews)];
    navigationTapGesture.numberOfTapsRequired = 1;
    [self.transparentTouchableNavigationView addGestureRecognizer:navigationTapGesture];
    [self.navigationController.navigationBar addSubview:self.transparentTouchableNavigationView];
    
    // Removes any/all 'delete' buttons on tableViewCell while transparent views are visible
    [self.tableView reloadData];
    
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
    
    // Remove leading and trailing whitespaces (queries separated by multiple white-spaces in between words are not affected).
    self.searchBar.text = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // Convert to current and previous strings to lowerCase for comparison
    NSString *lowerCaseQuery = [self.searchBar.text lowercaseString];
    NSMutableArray *lowerCaseArray = [self.previousQueriesArray mutableCopy];
    for ( NSString *previousQuery in self.previousQueriesArray ) [lowerCaseArray addObject:[previousQuery lowercaseString]];

    if ( [lowerCaseArray count] ) { // If this IS NOT the first search query
        
        if ( ![lowerCaseArray containsObject:lowerCaseQuery] ) {

            NSArray *reversedArray = [[self.previousQueriesArray reverseObjectEnumerator] allObjects];
            [self.previousQueriesArray removeAllObjects];
            [self.previousQueriesArray addObjectsFromArray:reversedArray];
            [self.previousQueriesArray addObject:self.searchBar.text];
            NSArray *secondReversedArray = [[self.previousQueriesArray reverseObjectEnumerator] allObjects];
            [self.previousQueriesArray removeAllObjects];
            [self.previousQueriesArray addObjectsFromArray:secondReversedArray];
            
        
            if ( [self.previousQueriesArray count] > kMaximumNumberOfQueries) [self.previousQueriesArray removeLastObject];
            [self savePreviousQueriesArray];
            [self.tableView reloadData];
            
        }
        
    } else { // If this IS the first search query

        [self.previousQueriesArray addObject:self.searchBar.text];
        [self savePreviousQueriesArray];
        [self.tableView reloadData];

    }
    
}

- (void)savePreviousQueriesArray
{
    [[NSUserDefaults standardUserDefaults] setObject:self.previousQueriesArray forKey:kPreviousQueries];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeTransparentViews
{
    // Resign Keyboard if any view element is touched that isn't currently a firstResponder UISearchBar object
    if ( [self.searchBar isFirstResponder] ) [self.searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.25f animations:^{ self.tableView.alpha = 1.0f; }];
    [self.transparentTouchableView removeFromSuperview];
    [self.transparentTouchableNavigationView removeFromSuperview];

}

- (void)createGeniusRoll
{
    GeniusRollViewController *geniusRollViewController = [[GeniusRollViewController alloc] initWithQuery:self.searchBar.text];
    [self.navigationController pushViewController:geniusRollViewController animated:YES];
    self.searchBar.text = @"";
}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.25f animations:^{ self.tableView.alpha = 0.25f; }];
    [self createTransparentTouchableViews];
}

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = [self.previousQueriesArray count];
    return (rows) ? rows : 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {

        [self.previousQueriesArray removeObjectAtIndex:indexPath.row];
        [self savePreviousQueriesArray];
        [self.tableView reloadData];
        
    }

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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
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
    
    // Create view for UITableView section header
    UIView *view = [[UIView alloc] initWithFrame:tableSectionHeaderFrame];
    
    // Background (issue with RGB-UIColor)
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableSectionHeaderBackground"]];
    [view addSubview:backgroundView];
    
    // 1px border on the bottom of the section header
    UIImageView *borderView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                            -1.0f + tableView.sectionFooterHeight,
                                                                            tableView.bounds.size.width,
                                                                            1.0f)];
    borderView.image = [UIImage imageNamed:@"tableViewBorder"];
    [view addSubview:borderView];
    
    
    // Section header label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f + tableSectionHeaderFrame.origin.x,
                                                               2.0f + tableSectionHeaderFrame.origin.y,
                                                               -10.0f + tableSectionHeaderFrame.size.width,
                                                               -2.0f + tableSectionHeaderFrame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Ubuntu-Bold" size:13];
    label.text = @"Previous Genius Searches";
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
    QueryCell *cell = (QueryCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    GeniusRollViewController *geniusRollViewController = [[GeniusRollViewController alloc] initWithQuery:cell.label.text];
    [self.navigationController pushViewController:geniusRollViewController animated:YES];
}

#pragma mark - UIResponder Methods
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( [self.searchBar isFirstResponder] ) [self removeTransparentViews];
}

#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
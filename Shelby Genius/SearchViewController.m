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

// C Libraries
#include <stdlib.h>

@interface SearchViewController ()

@property (strong, nonatomic) NSMutableArray *previousQueriesArray;
@property (strong, nonatomic) NSArray *searchTerms;
@property (strong, nonatomic) UIView *transparentTouchableView;
@property (strong, nonatomic) UIView *transparentTouchableNavigationView;

- (void)customize;
- (void)changePlaceholder;
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
@synthesize searchButton = _searchButton;
@synthesize previousQueriesArray = _previousQueriesArray;
@synthesize searchTerms = searchTerms;
@synthesize transparentTouchableView = _transparentTouchableView;
@synthesize transparentTouchableNavigationView = _transparentTouchableNavigationView;

#pragma mark - View Lifecycle Methods
- (void)viewDidUnload
{
    self.tableView = nil;
    self.searchBar = nil;
    self.searchButton = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customize];
    [self initializePreviousQueriesArray];
}

 - (void)viewDidAppear:(BOOL)animated
{
    // searchButton
    [self.searchButton setEnabled:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeTransparentViews];
}

#pragma mark - Public Methods
- (void)searchButtonAction:(id)sender
{
    [self removeTransparentViews];
    [self modifyPreviousQueriesArray];
    [self createGeniusRoll];
}

#pragma mark - Private Methods
- (void)customize
{
    // view
    self.view.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    
    // tableView
    self.tableView.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    self.tableView.scrollEnabled = NO;
    
    // searchBar
    [(UITextField*)[self.searchBar.subviews objectAtIndex:1] setFont:[UIFont fontWithName:@"Ubuntu" size:13]];
    self.searchBar.backgroundImage = [UIImage imageNamed:@"searchBar"];
    
    // Hide backbarButtonItem if GeniusOnboardingViewController was displayed    
    if ( self != [self.navigationController.viewControllers objectAtIndex:0] ) {
        [self.navigationItem setHidesBackButton:YES];
        UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationLogo"]];
        self.navigationItem.titleView = logoView;
    }
}

- (void)changePlaceholder
{
    
    if ( ![self searchTerms] ) {
        
        // Path to Property Lists that store watch components information
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchTerms" ofType:@"plist"];
        
        // Read dictionary data from each watchPath
        NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        // Populate watchArray with objects from watchDictionary
        self.searchTerms = [[NSArray alloc] initWithArray:(NSArray*)[dictionary objectForKey:@"searchTerms"]];
        
    }
    

    NSUInteger randomNumber = arc4random_uniform([self.searchTerms count]);
    self.searchBar.placeholder = [NSString stringWithFormat:@"How about ‘%@’?",[self.searchTerms objectAtIndex:randomNumber]];
    
}

- (void)createTransparentTouchableViews
{
    
    // Disable clicakble 'delete' buttons on tableViewCell while transparent views are visible
    self.tableView.userInteractionEnabled = NO;
    
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
    if ( [self.searchBar isFirstResponder] ) {
    
        [self.searchBar resignFirstResponder];
        [self.searchBar setPlaceholder:@"Genius Search"];
    }
    
    [self.transparentTouchableView removeFromSuperview];
    [self.transparentTouchableNavigationView removeFromSuperview];
    self.tableView.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.25f animations:^{ self.tableView.alpha = 1.0f; }];
    
}

- (void)createGeniusRoll
{
    GeniusRollViewController *geniusRollViewController = [[GeniusRollViewController alloc] initWithQuery:self.searchBar.text];
    [self.navigationController pushViewController:geniusRollViewController animated:YES];
    self.searchBar.text = @"";
}

#pragma mark - UISearchBarDelegate Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if (searchBar.text.length>0) {
        
        [self.searchButton setEnabled:YES];
        
    } else {
        
        [self.searchButton setEnabled:NO];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self createTransparentTouchableViews];
    [self changePlaceholder];
    [UIView animateWithDuration:0.25f animations:^{ self.tableView.alpha = 0.25f; }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self removeTransparentViews];
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
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QueryCell" owner:self options:nil];
        QueryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueryCell"];
        if ( nil == cell ) cell = (QueryCell*)[nib objectAtIndex:0];
        
        cell.label.text = [self.previousQueriesArray objectAtIndex:indexPath.row];
        
        return cell;
        
    } else {

        tableView.alpha = 0.0f;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }

}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([self.previousQueriesArray count]) ? 27.0f : 0.0f;
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f + tableSectionHeaderFrame.origin.x,
                                                               5.0f + tableSectionHeaderFrame.origin.y,
                                                               -20.0f + tableSectionHeaderFrame.size.width,
                                                               -2.0f + tableSectionHeaderFrame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Ubuntu-Medium" size:14];
    label.text = @"Previous Genius Searches";
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor colorWithRed:68.0f/255.0f green:68.0f/255.0f  blue:68.0f/255.0f  alpha:1.0f];
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
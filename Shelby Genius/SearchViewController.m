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

// View Controllers
#import "GeniusRollViewController.h"

// C Libraries
#include <stdlib.h>

@interface SearchViewController ()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableArray *previousQueriesArray;
@property (strong, nonatomic) NSArray *searchTerms;
@property (copy, nonatomic) NSString *placeholderQuery;
@property (strong, nonatomic) UIView *transparentTouchableView;
@property (strong, nonatomic) UIView *transparentTouchableNavigationView;

- (void)customize;
- (void)changePlaceholder;
- (void)createTransparentTouchableViews;
- (void)removeTransparentViews;
- (void)initializePreviousQueriesArray;
- (void)modifyPreviousQueriesArray;
- (void)toggleTableViewScrolling;
- (void)savePreviousQueriesArray;
- (void)createGeniusRoll;
- (void)noResultsReturned;

@end

@implementation SearchViewController
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize searchButton = _searchButton;
@synthesize onboardingImageView = _onboardingImageView;
@synthesize appDelegate = _appDelegate;
@synthesize previousQueriesArray = _previousQueriesArray;
@synthesize searchTerms = searchTerms;
@synthesize placeholderQuery = _placeholderQuery;
@synthesize transparentTouchableView = _transparentTouchableView;
@synthesize transparentTouchableNavigationView = _transparentTouchableNavigationView;

#pragma mark - Memory Management Methods
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoResultsReturnedObserver object:nil];
    
    self.tableView = nil;
    self.searchBar = nil;
    self.searchButton = nil;
    self.onboardingImageView = nil;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customize];
    [self initializePreviousQueriesArray];
    
    BOOL previouslyLaunched = [[NSUserDefaults standardUserDefaults] boolForKey:kPreviouslyLaunched];
    
    if ( previouslyLaunched ) { // If application was previously launched
        
        [[KISSMetricsController sharedInstance] sendActionToKISSMetrics:KISSMetricsStatistic_RepeatUser andMetrics:nil];
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPreviouslyLaunched];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[KISSMetricsController sharedInstance] sendActionToKISSMetrics:KISSMetricsStatistic_FirstTimeUser andMetrics:nil];
    }

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self toggleTableViewScrolling];
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
    // KISSMetrics Analytics
    NSString *currentQuery = ( self.searchBar.text.length > 0 ) ? self.searchBar.text : self.placeholderQuery;
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:currentQuery, KISSQuery, nil];
    [[KISSMetricsController sharedInstance] sendActionToKISSMetrics:KISSMetricsStatistic_PerformQuery andMetrics:metrics];
    
    [self removeTransparentViews];
    [self modifyPreviousQueriesArray];
    [self createGeniusRoll];
}

#pragma mark - Private Methods
- (void)customize
{
    // App Delegate
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // view
    self.view.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    
    // tableView
    self.tableView.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    self.tableView.scrollEnabled = NO;
    
    // searchBar
    self.searchBar.backgroundImage = [UIImage imageNamed:@"searchBar"];
    for (id subview in self.searchBar.subviews) {
        if ([subview respondsToSelector:@selector(setEnablesReturnKeyAutomatically:)]) {
            [subview setEnablesReturnKeyAutomatically:NO];
            break;
        }
    }

    // Modify UITextField Font
    [(UITextField*)[self.searchBar.subviews objectAtIndex:1] setFont:[UIFont fontWithName:@"Ubuntu" size:13]];
    
    // Observer for failed API Calls
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noResultsReturned)
                                                 name:kNoResultsReturnedObserver
                                               object:nil];
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
    self.searchBar.placeholder = [NSString stringWithFormat:@"How about ‘%@’?", [self.searchTerms objectAtIndex:randomNumber]];
    self.placeholderQuery = [self.searchTerms objectAtIndex:randomNumber];
    
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
    if ( [self.previousQueriesArray count] )[UIView animateWithDuration:0.25f animations:^{ self.tableView.alpha = 1.0f; }];
    
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
    NSString *currentQuery = (self.searchBar.text.length > 0) ? self.searchBar.text : self.placeholderQuery;
    currentQuery= [currentQuery stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Convert to current and previous strings to lowerCase for comparison
    NSString *lowerCaseQuery = [currentQuery lowercaseString];
    NSMutableArray *lowerCaseArray = [self.previousQueriesArray mutableCopy];
    for ( NSString *previousQuery in self.previousQueriesArray ) [lowerCaseArray addObject:[previousQuery lowercaseString]];

    if ( [lowerCaseArray count] ) { // If this IS NOT the first search query in previousQueriesArray
        
        if ( ![lowerCaseArray containsObject:lowerCaseQuery] ) {

            // Sort array so tableView DataSource methods display the results in reverse chronological order
            NSArray *reversedArray = [[self.previousQueriesArray reverseObjectEnumerator] allObjects];
            [self.previousQueriesArray removeAllObjects];
            [self.previousQueriesArray addObjectsFromArray:reversedArray];
            [self.previousQueriesArray addObject:currentQuery];
            NSArray *secondReversedArray = [[self.previousQueriesArray reverseObjectEnumerator] allObjects];
            [self.previousQueriesArray removeAllObjects];
            [self.previousQueriesArray addObjectsFromArray:secondReversedArray];

            // Enable/Disable tableView scrolling
            [self toggleTableViewScrolling];
            
            // Remove last object if upper-limit of saved search queries was reached
            if ( [self.previousQueriesArray count] > kMaximumNumberOfQueries) {
                [self.previousQueriesArray removeLastObject];
            }
            
            [self savePreviousQueriesArray];
            [self.tableView reloadData];
            
        }
        
        
    } else { // If this IS the first search query in previousQueriesArray

        NSString *firstQuery = (self.searchBar.text.length > 0) ? self.searchBar.text : self.placeholderQuery;
        [self.previousQueriesArray addObject:firstQuery];
        [self savePreviousQueriesArray];
        [self.tableView reloadData];

    }
    
}

- (void)toggleTableViewScrolling
{
    // Enable/Disable scorlling
    if ( [self.previousQueriesArray count] >= 5) {
        [self.tableView setScrollEnabled:YES];
    } else {
        [self.tableView setScrollEnabled:NO];
    }
}

- (void)savePreviousQueriesArray
{
    [[NSUserDefaults standardUserDefaults] setObject:self.previousQueriesArray forKey:kPreviousQueries];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)createGeniusRoll
{
    NSString *currentQuery = (self.searchBar.text.length > 0) ? self.searchBar.text : self.placeholderQuery;
    currentQuery= [currentQuery stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    GeniusRollViewController *geniusRollViewController = [[GeniusRollViewController alloc] initWithNibName:@"GeniusRollViewController_iphone" bundle:nil andQuery:currentQuery];
    [self.navigationController pushViewController:geniusRollViewController animated:YES];
    self.searchBar.text = @"";
}

- (void)noResultsReturned
{
    [self.appDelegate addHUDWithMessage:@"No Results Found"];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self.appDelegate selector:@selector(removeHUD) userInfo:nil repeats:NO];
}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchButton setEnabled:YES];
    [self createTransparentTouchableViews];
    [self changePlaceholder];
    
    [UIView animateWithDuration:0.25f animations:^{ self.tableView.alpha = 0.25f; }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ( self.searchBar.text.length > 0) { // use user's query

        // KISSMetrics Analytics
        NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.searchBar.text, KISSQuery, nil];
        [[KISSMetricsController sharedInstance] sendActionToKISSMetrics:KISSMetricsStatistic_PerformQuery andMetrics:metrics];
        
    } else { // use placeholderQuery
        
        NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:self.placeholderQuery, KISSQuery, nil];
        [[KISSMetricsController sharedInstance] sendActionToKISSMetrics:KISSMetricsStatistic_PerformQuery andMetrics:metrics];
        
    }

    
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
        [self toggleTableViewScrolling];
        [self savePreviousQueriesArray];
        [self.tableView reloadData];
        
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.previousQueriesArray count] ) {
        
        self.onboardingImageView.alpha = 0.0f;
        tableView.alpha = 1.0f;
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"QueryCell_iphone" owner:self options:nil];
        QueryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueryCell"];
        if ( nil == cell ) cell = (QueryCell*)[nib objectAtIndex:0];
        
        cell.label.text = [self.previousQueriesArray objectAtIndex:indexPath.row];
        
        return cell;
        
    } else {

        self.onboardingImageView.alpha = 1.0f;
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
    
    if ( kSystemVersion6 ) {
        
        label.textAlignment = NSTextAlignmentLeft;
        
    } else {
        
        label.textAlignment = UITextAlignmentLeft;
        
    }
    
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
    
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:cell.label.text, KISSQuery, nil];
    [[KISSMetricsController sharedInstance] sendActionToKISSMetrics:KISSMetricsStatistic_PerformQuery andMetrics:metrics];
        
    GeniusRollViewController *geniusRollViewController = [[GeniusRollViewController alloc] initWithNibName:@"GeniusRollViewController_iphone" bundle:nil andQuery:cell.label.text];
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
    if ( kDeviceIsIPad) {
        return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

@end
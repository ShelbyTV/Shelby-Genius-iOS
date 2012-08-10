//
//  ASPullToRefreshTableViewController.m
//
//  Created by Arthur Sabintsev on 02/14/12.
//  Copyright © 2012 Arthur Sabintsev
//  
//  Originall created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "ASPullToRefreshTableViewController.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - Macros

#define     kREFRESH_HEADER_HEIGHT      70.0f
#define     kTEXT_PULL                  @"Pull down to refresh..."
#define     kTEXT_RELEASE               @"Release to refresh..."
#define     kTEXT_LOADING               @"Loading..."
#define     kPullToRefreshArrow         @"pullToRefreshArrow"

#pragma mark - Private Declarations

@interface ASPullToRefreshTableViewController ()

@property (assign, nonatomic) BOOL isDragging;                              // Monitors to monitor scroll state of table
@property (assign, nonatomic) BOOL isRefreshing;                            // Monitors refresh state of table
@property (strong, nonatomic) UILabel *refreshLabel;                        // Holds text to textually/visually delineate the table's refresh state
@property (strong, nonatomic) UILabel *refreshTimestampLabel;               // Holds timestamp of refresh
@property (strong, nonatomic) UIImageView *refreshArrow;                    // Indicates scroll direction to initiate table refresh
@property (strong, nonatomic) UIActivityIndicatorView *refreshSpinner;      // Indicates refresh is in progress
@property (strong, nonatomic) UIView *refreshHeaderView;                    // The refresh header 

- (void)createPullToRefreshHeader;                                          // Create Pull-To-Refresh Header
- (void)didBeginRefreshing;                                                 // Begins the refresh process
- (void)didFinishRefreshing;                                                // Ends the refresh process
- (void)resetRefreshState;                                                  // Resets variables for next refresh
- (NSString*)refreshTimestamp;                                              // Returns time of refresh

@end

@implementation ASPullToRefreshTableViewController
@synthesize refreshDelegate = _refreshDelegate;
@synthesize refreshLabel = _refreshLabel; 
@synthesize refreshTimestampLabel = _refreshTimestampLabel;
@synthesize refreshArrow = _refreshArrow; 
@synthesize refreshSpinner = _refreshSpinner; 
@synthesize refreshHeaderView = _refreshHeaderView; 
@synthesize isRefreshing = _isRefreshing; 
@synthesize isDragging = _isDragging;

#pragma mark - View Lifecycle Methods
- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self createPullToRefreshHeader];
}

#pragma mark - Create Pull-To-Refresh Header Method
- (void)createPullToRefreshHeader 
{
    
    // Create UIView to mimic UITableView's tableHeaderView
    self.refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -kREFRESH_HEADER_HEIGHT, self.view.frame.size.width, kREFRESH_HEADER_HEIGHT)];
    self.refreshHeaderView.backgroundColor = [UIColor clearColor];
    self.refreshHeaderView.autoresizesSubviews = YES;
    self.refreshHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Remove labels from Superview if they exist
    if (self.refreshLabel) [self.refreshLabel removeFromSuperview];
    if (self.refreshTimestampLabel) [self.refreshTimestampLabel removeFromSuperview];
    
    // Create refreshLabel that textually delineates the 'refresh-state' using strings (e.g., kTEXT_PULL, kTEXT_RELEASE, kTEXT_LOADING)
    self.refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, kREFRESH_HEADER_HEIGHT)];
    self.refreshLabel.autoresizesSubviews = YES;
    self.refreshLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.refreshLabel.backgroundColor = [UIColor clearColor];
    self.refreshLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    self.refreshLabel.textAlignment = UITextAlignmentCenter;
    self.refreshLabel.textColor = [UIColor whiteColor];
    [self.refreshHeaderView addSubview:self.refreshLabel];
    
    // Create refreshTimestampLabal that displays the last time the dataSource was refreshed
    self.refreshTimestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.view.frame.size.width, kREFRESH_HEADER_HEIGHT)];
    self.refreshTimestampLabel.autoresizesSubviews = YES;
    self.refreshTimestampLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.refreshTimestampLabel.backgroundColor = [UIColor clearColor];
    self.refreshTimestampLabel.font = [UIFont boldSystemFontOfSize:9.0f];
    self.refreshTimestampLabel.textColor = [UIColor grayColor];
    self.refreshTimestampLabel.textAlignment = UITextAlignmentCenter;
    [self.refreshHeaderView addSubview:self.refreshTimestampLabel];

    // Create refreshArrow to show the direction of the scroll (rotates directions when scrolling reaches value delineated by kREFRESH_HEADER_HEIGHT) 
    self.refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kPullToRefreshArrow]];
    self.refreshArrow.frame = CGRectMake(10.0f, 
                                         kREFRESH_HEADER_HEIGHT/2.0 - self.refreshArrow.frame.size.height/2.0, 
                                         self.refreshArrow.frame.size.width, 
                                         self.refreshArrow.frame.size.height);

    [self.refreshHeaderView addSubview:self.refreshArrow];
    
    // Create refreshSpinner (e.g., UIActivityIndicatorView)
    self.refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.refreshSpinner.frame = CGRectMake(floorf(floorf(kREFRESH_HEADER_HEIGHT - 20.0f) / 2.0f), floorf((kREFRESH_HEADER_HEIGHT - 20.0f) / 2.0f), 20.0f, 20.0f);
    self.refreshSpinner.hidesWhenStopped = YES;

    // Add refreshHeaderView to tableView view hiearchy
    [self.refreshHeaderView addSubview:self.refreshSpinner];
    [self.tableView addSubview:self.refreshHeaderView];

}

#pragma mark - Loading Methods
- (void)didBeginRefreshing 
{
    self.isRefreshing = YES;

    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsMake(kREFRESH_HEADER_HEIGHT, 0.0f, 0.0f, 0.0f);
    self.refreshLabel.text = kTEXT_LOADING;
    self.refreshArrow.hidden = YES;
    [self.refreshSpinner startAnimating];
    [UIView commitAnimations];

    // Refresh data
    [self.refreshDelegate dataToRefresh];
}

- (void)didFinishRefreshing 
{
    self.isRefreshing = NO;
    
    // Get refresh timestamp
    NSString *timeStamp = [self refreshTimestamp];
    
    // Set refreshTimestampLabel's text property with timestamp
    self.refreshTimestampLabel.text = [NSString stringWithFormat:@"Last refreshed on %@", timeStamp];
    
    // Move refreshLabel's frame up by 10 pixels to make room for refreshTimestampLabel's text output
    self.refreshLabel.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, kREFRESH_HEADER_HEIGHT);
    self.refreshTimestampLabel.frame = CGRectMake(0.0f, 10.0f, self.view.frame.size.width, kREFRESH_HEADER_HEIGHT);

    // Hide the header (via animation)
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(resetRefreshState)];
    self.tableView.contentInset = UIEdgeInsetsZero;
    UIEdgeInsets tableContentInset = self.tableView.contentInset;
    tableContentInset.top = 0.0f;
    self.tableView.contentInset = tableContentInset;
    self.refreshArrow.layer.transform = CATransform3DMakeRotation(M_PI * 2.0f, 0.0f, 0.0f, 1.0f);
    [UIView commitAnimations];
}

- (void)resetRefreshState 
{
    self.refreshLabel.text = kTEXT_PULL;
    self.refreshArrow.hidden = NO;
    [self.refreshSpinner stopAnimating];
}

#pragma mark - Refresh Timestamp Method
- (NSString*)refreshTimestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. d, YYY 'at' h:mm a"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
    
    self.isDragging = YES;
    
    // If app is loading, escape method to avoid multiple calls to refresh
    if (self.isRefreshing) return;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{

    if (self.isDragging && scrollView.contentOffset.y < 0) { /// Update the arrow direction and label
    
        [UIView beginAnimations:nil context:NULL];
        
        if (scrollView.contentOffset.y < -kREFRESH_HEADER_HEIGHT) {  /// User is scrolling above the header
           
            self.refreshLabel.text = kTEXT_RELEASE;
            self.refreshArrow.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
            
        } else { /// User is scrolling somewhere within the header
            
            self.refreshLabel.text = kTEXT_PULL;
            self.refreshArrow.layer.transform = CATransform3DMakeRotation(M_PI * 2.0f, 0.0f, 0.0f, 1.0f);
      
        }
        
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate 
{

    self.isDragging = NO;
    
    // If app is loading, escape method to avoid multiple didBeginRefreshing/refresh calls
    if (self.isRefreshing) return;
    
    // User is scrolling above the header
    if (scrollView.contentOffset.y < -kREFRESH_HEADER_HEIGHT) [self didBeginRefreshing];

}

#pragma mark - ASPullToRefreshDelegate Methods
- (void)dataToRefresh 
{    
    // Do nothing in ASPullToRefreshTableViewController
}

@end
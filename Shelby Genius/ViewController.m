//
//  ViewController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "ViewController.h"
#import "APIClient.h"
#import "VideoCardCell.h"
#import "AsynchronousFreeloader.h"
#import "VideoPlayerViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray *resultsArray;

- (void)makeResultsArray:(NSNotification*)notification;

@end

@implementation ViewController
@synthesize tableView = _tableView;
@synthesize textField = _textField;
@synthesize button = _button;
@synthesize resultsArray = _resultsArray;

#pragma mark - View Lifecycle Methods
- (void)viewDidUnload
{
    self.tableView = nil;
    self.textField = nil;
    self.button = nil;
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

#pragma mark - Action Methods
- (IBAction)search:(id)sender
{

    // Hide keyboard
    if ( [self.textField isFirstResponder] ) [self.textField resignFirstResponder];
    
    if ( self.textField.text.length ) {
        
        APIClient *client = [[APIClient alloc] init];
        NSString *requestString = [NSString stringWithFormat:kGetQuery, self.textField.text];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
        
        [client performRequest:request ofType:APIRequestType_GetQuery withQuery:self.textField.text];
        
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
        self.resultsArray = [[notification.userInfo objectForKey:@"result"] valueForKey:@"frames"];
        
    } else {
     
        [self.resultsArray addObjectsFromArray:[[notification.userInfo objectForKey:@"result"] valueForKey:@"frames"]];
        
    }
    
    [self.tableView reloadData];

}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Hide keyboard when DONE button is pressed
    if( [string isEqualToString:@"\n"] ) {
        
        [textField resignFirstResponder];
        
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [self search:textField];
    
    return YES;
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
        
        NSString *thumbnailURL = [[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"thumbnail_url"];
        NSString *videoTitle = [[[self.resultsArray objectAtIndex:indexPath.row] valueForKey:@"video"] valueForKey:@"title"];
        
        [AsynchronousFreeloader loadImageFromLink:thumbnailURL forImageView:cell.thumbnailImageView withPlaceholderView:nil];
        cell.videoTitleLabel.text = videoTitle;
        
        return cell;
        
    } else {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewStyleGrouped reuseIdentifier: @"Cell"];
        cell.textLabel.text = @"Search for Something";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        return cell;
    
    }

}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end

//
//  GeniusOnboardingViewController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/25/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "GeniusOnboardingViewController.h"
#import "SearchViewController.h"

@interface GeniusOnboardingViewController ()

@end

@implementation GeniusOnboardingViewController

#pragma mark - View Lifecycle Methods
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Action Methods
- (void)pushSearchViewController:(id)sender
{
    SearchViewController *searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController_iPhone" bundle:nil];
    [self.navigationController pushViewController:searchViewController animated:YES];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPreviouslyLaunched];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

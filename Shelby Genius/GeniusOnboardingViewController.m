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
    
    // Due to animation, appearance proxy isn't hit, so we have to resort to adding it here
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationLogo"]];
    self.navigationController.visibleViewController.navigationItem.titleView = logoView;
    
}

#pragma mark - Action Methods
- (void)pushSearchViewController:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPreviouslyLaunched];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
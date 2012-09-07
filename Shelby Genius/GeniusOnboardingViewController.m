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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Due to animation, appearance proxy isn't hit, so we have to resort to adding it here
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationLogo"]];
    self.navigationController.visibleViewController.navigationItem.titleView = logoView;
    [self.navigationItem setHidesBackButton:YES];
}

#pragma mark - Action Methods
- (void)pushSearchViewController:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPreviouslyLaunched];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Interface Orientation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ( kDeviceIsIPad) {
        return UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
    } else {
        return UIInterfaceOrientationPortrait;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
//    return UIInterfaceOrientationMaskPortrait;
    return 2;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
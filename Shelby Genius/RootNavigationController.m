//
//  RootNavigationController.m
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/30/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "RootNavigationController.h"
#import "VideoPlayerViewController.h"

@interface RootNavigationController ()

@end

@implementation RootNavigationController

#pragma mark - Interface Orientation Methods (iOS 6)
- (NSUInteger)supportedInterfaceOrientations
{
    if ( [self.visibleViewController isKindOfClass:[VideoPlayerViewController class]] ) {
    //  return UIInterfaceOrientationMaskAllButUpsideDown;
        return 26;
    } else {
    // return UIInterfaceOrientationMaskPortrait;
        return 2;
    }
}

- (BOOL)shouldAutorotate
{
    if ([self.visibleViewController isKindOfClass:[VideoPlayerViewController class]]) { // VideoPlayerViewController
        
        if ( kDeviceIsIPad) { // iPad
        
            return NO;
            
        } else { // iPhone
            
            return YES;
            
        }
        
    } else { // All other classes
    
        return NO;
   
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    if ( kDeviceIsIPad ) {
        
        return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
        
    } else {
        
        return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
        
    }
    
}


@end

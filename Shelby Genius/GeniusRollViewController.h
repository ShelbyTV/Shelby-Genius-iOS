//
//  GeniusRollViewController.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/13/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeniusRollViewController : UIViewController 
<
UITableViewDataSource,
UITableViewDelegate,
UIActionSheetDelegate
>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *query;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andQuery:(NSString*)query;

@end
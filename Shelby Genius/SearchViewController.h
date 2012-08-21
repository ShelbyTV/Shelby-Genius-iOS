//
//  SearchViewController.h
//  Shelby Genius
//
//  Created by Arthur Ariel Sabintsev on 8/10/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

- (IBAction)searchButtonAction:(id)sender;

@end

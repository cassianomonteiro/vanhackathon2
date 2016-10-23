//
//  NewsFeedVC.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 21/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsFeedVC : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginTapped:(UIBarButtonItem *)sender;
- (IBAction)postTapped:(UIBarButtonItem *)sender;

@end

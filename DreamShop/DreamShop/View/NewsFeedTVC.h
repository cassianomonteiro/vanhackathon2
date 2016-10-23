//
//  NewsFeedTVC.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 23/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dream.h"
#import "SignInManager.h"

@interface NewsFeedTVC : UITableViewController

@property (nonatomic, strong) NSArray<Dream *> *dreams;
@property (nonatomic, strong) SignInManager *signInManager;

- (instancetype)initWithTableView:(UITableView *)tableView;

@end

//
//  NewsFeedTVC.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 23/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "NewsFeedTVC.h"
#import <FontAwesomeIconFactory.h>
#import <UIImageView+AFRKNetworking.h>
#import "SimpleImageCell.h"
#import "DreamCell.h"

@implementation NewsFeedTVC

#pragma mark - Initialization

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return self;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: // Section "What is your dream?"
            return 1;
            break;
        case 1: // Section with dreams news need
            return self.dreams.count;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return [self tableView:tableView userDreamCellForRowAtIndexPath:indexPath];
            break;
        case 1:
            return [DreamCell dequeueCellFromTableView:tableView withDream:self.dreams[indexPath.row]];
        break;
            default:
            return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView userDreamCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimpleImageCell *cell = [tableView dequeueReusableCellWithIdentifier:[SimpleImageCell cellID]];
    
    if (!cell) {
        cell = [[SimpleImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[SimpleImageCell cellID]];
    }
    
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory buttonIconFactory];
    factory.size = [SimpleImageCell cellHeight];
    UIImage *userImage = [factory createImageForIcon:NIKFontAwesomeIconUser];
    
    cell.cellImageView.image = nil;
    if (self.signInManager.user.photoURL) {
        [cell.cellImageView setImageWithURL:self.signInManager.user.photoURL placeholderImage:userImage];
    }
    else {
        cell.cellImageView.image = userImage;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4.f;
            break;
        case 1:
            return 1.f;
            break;
        default:
            return 0.f;
            break;
    }
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 77.f;
            break;
        case 1:
            return [DreamCell cellHeight];
            break;
        default:
            return 0;
            break;
    }
}

@end

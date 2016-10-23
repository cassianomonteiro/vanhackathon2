//
//  DreamCell.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dream.h"

@interface DreamCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *dreamImageView;
@property (weak, nonatomic) IBOutlet UILabel *dreamDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *subCategoryLabel;

+ (NSString *)cellID;
+ (CGFloat)cellHeight;

+ (DreamCell *)dequeueCellFromTableView:(UITableView *)tableView withDream:(Dream *)dream;
@end

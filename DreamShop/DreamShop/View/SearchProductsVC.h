//
//  SearchProductsVC.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@end

@interface SearchProductsVC : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
- (IBAction)cancelTapped:(UIBarButtonItem *)sender;
@end

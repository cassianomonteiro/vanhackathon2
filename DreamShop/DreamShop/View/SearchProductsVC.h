//
//  SearchProductsVC.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Buy/Buy.h>

@interface SearchProductsVC : UITableViewController

@property (nonatomic, strong) BUYProduct *selectedProduct;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
- (IBAction)cancelTapped:(UIBarButtonItem *)sender;
@end

//
//  NewDreamVC.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 23/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface NewDreamVC : UIViewController

@property (nonatomic, strong) User *user;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedSubCategoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *selectedCategory;
@property (weak, nonatomic) IBOutlet UILabel *selectedSubCategory;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray<UIImageView *> *categories;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray<UIImageView *> *subCategories;

@property (weak, nonatomic) IBOutlet UITextField *dreamTextField;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *youtubeButton;
@property (weak, nonatomic) IBOutlet UIButton *shopifyButton;

- (IBAction)photoTapped:(UIButton *)sender;
- (IBAction)youtubeTapped:(UIButton *)sender;
- (IBAction)postTapped:(UIBarButtonItem *)sender;

@end

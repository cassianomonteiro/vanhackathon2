//
//  NewDreamVC.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 23/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "NewDreamVC.h"
#import <FontAwesomeIconFactory.h>
#import <UIImageView+AFRKNetworking.h>
#import "AlertControllerFactory.h"
#import "Dream.h"

@interface NewDreamVC () <UITextFieldDelegate>
@end

@implementation NewDreamVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userNameLabel.text = self.user.name;
    self.selectedCategory.text = @"";
    self.selectedSubCategory.text = @"";
    
    [self setUpImages];
    [self setUpCategories];
    [self setUpGestureRecognizers];
    
    self.postButton.enabled = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (void)categoryTapped:(UITapGestureRecognizer *)sender
{
    UIImageView *imageView = (UIImageView *)sender.view;
    self.selectedCategory.text = self.categoriesNames[[self.categories indexOfObject:imageView]].capitalizedString;
    
    for (UIImageView *category in self.categories) {
        category.alpha = (category == imageView) ? 1.f : 0.3f;
    }
    
    [self validatePostButtonEnabling];
}

- (void)subCategoryTapped:(UITapGestureRecognizer *)sender
{
    UIImageView *imageView = (UIImageView *)sender.view;
    self.selectedSubCategory.text = self.subCategoriesNames[[self.subCategories indexOfObject:imageView]].capitalizedString;
    
    for (UIImageView *subCategory in self.subCategories) {
        subCategory.alpha = (subCategory == imageView) ? 1.f : 0.3f;
    }
    
    [self validatePostButtonEnabling];
}

- (void)viewTapped:(UITapGestureRecognizer *)sender
{
    if (self.dreamTextField.isFirstResponder) {
        [self.dreamTextField resignFirstResponder];
    }
}

- (IBAction)dreamTextChanged:(UITextField *)sender
{
    self.postButton.enabled = (sender.text.length > 0);
}

- (IBAction)photoTapped:(UIButton *)sender
{
    UIAlertController *alertController =
    [AlertControllerFactory photoSourceAlertControllerForViewController:self
                                                          withImageSize:self.photoImageView.frame.size
                                                      completionHandler:^(UIImage *image) {
                                                          NSLog(@"%@", self.photoImageView);
                                                          self.photoImageView.image = image;
                                                          NSLog(@"%@", self.photoImageView);
                                                      }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)youtubeTapped:(UIButton *)sender {
}

- (IBAction)postTapped:(UIBarButtonItem *)sender {
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.isFirstResponder) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Helpers

- (void)setUpImages
{
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory buttonIconFactory];
    
    factory.size = self.photoButton.frame.size.height*0.8;
    self.photoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.photoButton setImage:[factory createImageForIcon:NIKFontAwesomeIconCamera] forState:UIControlStateNormal];
    
    factory.size = self.youtubeButton.frame.size.height*0.8;
    factory.colors = @[[UIColor redColor]];
    self.youtubeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.youtubeButton setImage:[factory createImageForIcon:NIKFontAwesomeIconYoutubePlay] forState:UIControlStateNormal];
    
    if (self.user.photoURL) {
        [self.userImageView setImageWithURL:self.user.photoURL];
    }
    else {
        NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory buttonIconFactory];
        factory.size = self.userImageView.frame.size.height;
        self.userImageView.image = [factory createImageForIcon:NIKFontAwesomeIconUser];
    }
}

- (void)setUpCategories
{
    for (NSUInteger i = 0; i < self.categories.count; i++) {
        self.categories[i].image = [UIImage imageNamed:self.categoriesNames[i]];
        [self.categories[i] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(categoryTapped:)]];
        self.categories[i].userInteractionEnabled = YES;
    }
    
    for (NSUInteger i = 0; i < self.subCategories.count; i++) {
        self.subCategories[i].image = [UIImage imageNamed:self.subCategoriesNames[i]];
        [self.subCategories[i] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subCategoryTapped:)]];
        self.subCategories[i].userInteractionEnabled = YES;
    }
}

- (void)setUpGestureRecognizers
{
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)]];
    [self.photoImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)]];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:self.dreamTextField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self validatePostButtonEnabling];
    }];
}

- (void)validatePostButtonEnabling
{
    self.postButton.enabled = ![self.dreamTextField.text isEqualToString:@""] &&
                                ![self.selectedCategory.text isEqualToString:@""] &&
                                ![self.selectedSubCategory.text isEqualToString:@""];
}

- (NSArray<NSString *> *)categoriesNames
{
    return @[SubCategoryPopular,
             SubCategoryTravel,
             SubCategoryOutdoor,
             SubCategorySports,
             SubCategoryProducts,
             SubCategoryOthers];
}

- (NSArray<NSString *> *)subCategoriesNames
{
    return @[SubCategoryBeach,
             SubCategoryCamping,
             SubCategoryAdventure,
             SubCategoryDesert,
             SubCategoryTourism];
}

@end

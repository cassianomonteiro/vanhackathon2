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
#import "SearchProductsVC.h"
#import "AlertControllerFactory.h"
#import "FirebaseUploader.h"
#import "Dream.h"

@interface NewDreamVC () <UITextFieldDelegate>
@property (nonatomic, strong) BUYProduct *selectedProduct;
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

#pragma mark - Navigation

- (void)receiveUnwindFromProductSearch:(UIStoryboardSegue *)segue
{
    SearchProductsVC *sourceVC = segue.sourceViewController;
    self.selectedProduct = sourceVC.selectedProduct;
    [self updateImageWithShopifyProduct];
}

- (void)updateImageWithShopifyProduct
{
    if (!self.photoImageView.image && self.selectedProduct.images && self.selectedProduct.images.count > 0) {
        BUYImageLink *imageLink = self.selectedProduct.images.firstObject;
        [self.photoImageView setImageWithURL:[imageLink imageURLWithSize:BUYImageURLSize1024x1024]];
    }
    else if (self.photoImageView.image) {
        [self addProductImageToImageView:self.photoImageView];
    }
    
    [self addShopifyIconToImageView:self.photoImageView];
}

- (void)addShopifyIconToImageView:(UIImageView *)imageView
{
    if (self.selectedProduct) {
        CGRect iconFrame = CGRectMake(imageView.frame.size.width - 38.f,
                                      imageView.frame.size.height - 38.f,
                                      30.f,
                                      30.f);
        
        UIImageView *shopifyImageView = [[UIImageView alloc] initWithFrame:iconFrame];
        shopifyImageView.contentMode = UIViewContentModeScaleAspectFit;
        shopifyImageView.image = [UIImage imageNamed:@"shopify-bag"];
        [imageView addSubview:shopifyImageView];
    }
}

- (void)addProductImageToImageView:(UIImageView *)imageView
{
    if (self.selectedProduct.images && self.selectedProduct.images.count > 0) {
        CGRect iconFrame = CGRectMake(imageView.frame.size.width - 76.f,
                                      imageView.frame.size.height - 38.f,
                                      30.f,
                                      30.f);
        
        BUYImageLink *imageLink = self.selectedProduct.images.firstObject;
        UIImageView *productImageView = [[UIImageView alloc] initWithFrame:iconFrame];
        productImageView.contentMode = UIViewContentModeScaleAspectFit;
        productImageView.backgroundColor = [UIColor whiteColor];
        [productImageView setImageWithURL:[imageLink imageURLWithSize:BUYImageURLSize100x100]];
        [imageView addSubview:productImageView];
    }
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
    self.selectedSubCategoryImageView.image = imageView.image;
    
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
                                                          self.photoImageView.image = image;
                                                          [self addProductImageToImageView:self.photoImageView];
                                                      }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setPhotoImage:(UIImage *)image
{
    // Remove any previous icons from photoImageView
    for (UIView *view in self.photoImageView.subviews) {
        [view removeFromSuperview];
    }
    
    self.photoImageView.image = image;
    [self addShopifyIconToImageView:self.photoImageView];
    [self addProductImageToImageView:self.photoImageView];
}

- (IBAction)youtubeTapped:(UIButton *)sender
{
}

- (IBAction)postTapped:(UIBarButtonItem *)sender
{
    self.view.userInteractionEnabled = NO;
    self.view.alpha = 0.3f;
    [self.activityIndicator startAnimating];
    
    [FirebaseUploader uploadImage:self.photoImageView.image withCompletionHandler:^(NSURL *imageURL) {
        self.view.userInteractionEnabled = YES;
        self.view.alpha = 1.f;
        [self.activityIndicator stopAnimating];
        NSLog(@"%@", imageURL);
    }];
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

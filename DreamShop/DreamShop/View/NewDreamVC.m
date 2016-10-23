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
#import "YouTubeHandler.h"
#import "FirebaseUploader.h"
#import "ConnectionManager.h"
#import "Dream.h"

#define unwindAfterCreatingDream @"unwindAfterCreatingDream"

@interface NewDreamVC () <UITextFieldDelegate, ConnectionManagerDelegate>
@property (nonatomic, strong) BUYProduct *selectedProduct;
@property (nonatomic, strong) UIImage *selectedPhoto;
@property (nonatomic, strong) NSString *youtubeURL;
@property (nonatomic, strong) NSURL *uploadedPhotoURL;
@property (nonatomic, strong) NSMutableArray<Layer *> *layers;
@end

@implementation NewDreamVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userNameLabel.text = self.user.name;
    self.selectedCategory.text = @"";
    self.selectedSubCategory.text = @"";
    self.layers = [NSMutableArray arrayWithCapacity:3];
    
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
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[imageLink imageURLWithSize:BUYImageURLSize1024x1024]];
        
        [self.photoImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            self.photoImageView.image = image;
            [self validatePostButtonEnabling];
        } failure:nil];
    }
    else if (self.photoImageView.image) {
        [self addProductImageToImageView:self.photoImageView];
    }
    
    [self addShopifyIconToView:self.photoImageView];
    [self addYoutubeIconToView:self.photoImageView];
    [self.view bringSubviewToFront:self.photoImageView];
}

- (void)addShopifyIconToView:(UIView *)view
{
    if (self.selectedProduct) {
        CGRect iconFrame = CGRectMake(view.frame.size.width - 38.f,
                                      view.frame.size.height - 38.f,
                                      30.f,
                                      30.f);
        
        UIImageView *shopifyImageView = [[UIImageView alloc] initWithFrame:iconFrame];
        shopifyImageView.contentMode = UIViewContentModeScaleAspectFit;
        shopifyImageView.image = [UIImage imageNamed:@"shopify-bag"];
        [view addSubview:shopifyImageView];
    }
    [self validatePostButtonEnabling];
}

- (void)addYoutTubeURL:(NSString *)youtubeURL
{
    NSString *youtubeID = [YouTubeHandler youTubeIDFromURL:youtubeURL];
    self.youtubeURL = youtubeURL;
    [self.playerView loadWithVideoId:youtubeID];
    [self.view bringSubviewToFront:self.playerView];
    [self addShopifyIconToView:self.playerView];
    [self addYoutubeIconToView:self.playerView];
}

- (void)addYoutubeIconToView:(UIView *)view
{
    if (self.youtubeURL) {
        CGRect iconFrame = CGRectMake(8.f,
                                      view.frame.size.height - 38.f,
                                      30.f,
                                      30.f);
        
        UIImageView *youtubeImageView = [[UIImageView alloc] initWithFrame:iconFrame];
        youtubeImageView.contentMode = UIViewContentModeScaleAspectFit;
        youtubeImageView.image = self.youtubeButton.imageView.image;
        youtubeImageView.backgroundColor = [UIColor whiteColor];
        [view addSubview:youtubeImageView];
    }
    [self validatePostButtonEnabling];
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
                                                          [self setPhotoImage:image];
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
    self.selectedPhoto = image;
    self.photoImageView.image = image;
    [self addYoutubeIconToView:self.photoImageView];
    [self addShopifyIconToView:self.photoImageView];
    [self addProductImageToImageView:self.photoImageView];
    [self.view bringSubviewToFront:self.photoImageView];
}

- (IBAction)youtubeTapped:(UIButton *)sender
{
    UIAlertController *youtubeAlerController =
    [AlertControllerFactory textFieldAlertControllerWithTitle:@"YouTube video"
                                                      andText:nil
                                               andPlaceHolder:@"YouTube link here!"
                                                   actionName:@"Save"
                                            completionHandler:^(NSString *text) {
        NSString *youtubeID = [YouTubeHandler youTubeIDFromURL:text];
        
        if (!youtubeID) {
            UIAlertController *warningAlertController = [AlertControllerFactory warningAlertControllerWithTitle:@"Invalid link!" andMessage:@"Please make sure to insert a valid YouTube link"];
            [self presentViewController:warningAlertController animated:YES completion:nil];
        }
        else {
            [self addYoutTubeURL:text];
        }
        
    }];
    
    [self presentViewController:youtubeAlerController animated:YES completion:nil];
}

- (IBAction)postTapped:(UIBarButtonItem *)sender
{
    [self startProgressAnimation];
    
    if (!self.selectedPhoto) {
        [self requestDreamCreation];
    }
    else {
        [FirebaseUploader uploadImage:self.photoImageView.image withCompletionHandler:^(NSURL *imageURL) {
            
            if (!imageURL) {
                [self stopProgressAnimation];
            }
            else {
                self.uploadedPhotoURL = imageURL;
                [self requestDreamCreation];
            }
        }];
    }
}

- (void)startProgressAnimation
{
    self.view.userInteractionEnabled = NO;
    self.view.alpha = 0.7f;
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)stopProgressAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = YES;
        self.view.alpha = 1.f;
        [self.activityIndicator stopAnimating];
    });
}

- (void)requestDreamCreation
{
    Dream *dream = [[Dream alloc] init];
    dream.user = self.user;
    dream.category = self.selectedCategory.text;
    dream.subCategory = self.selectedSubCategory.text;
    [[ConnectionManager defaultManager] requestDreamCreation:dream forDelegate:self];
}

- (void)prepareLayersToRequestCreationFromDream:(Dream *)dream
{
    if (self.selectedPhoto) {
        Layer *layer = [[Layer alloc] init];
        layer.dream = dream;
        layer.type = LayerTypePhoto;
        layer.layerDescription = self.dreamTextField.text;
        layer.layerURL = self.uploadedPhotoURL;
        [self.layers addObject:layer];
    }
    
    if (self.selectedProduct) {
        BUYImageLink *imageLink = self.selectedProduct.images.firstObject;
        Layer *layer = [[Layer alloc] init];
        layer.dream = dream;
        layer.type = LayerTypeProduct;
        layer.layerDescription = [NSString stringWithFormat:@"%@ %@", self.selectedProduct.vendor, self.selectedProduct.title];
        layer.productId = self.selectedProduct.identifier;
        layer.layerURL = [imageLink imageURLWithSize:BUYImageURLSize1024x1024];
        [self.layers addObject:layer];
    }
    
    if (self.youtubeURL) {
        Layer *layer = [[Layer alloc] init];
        layer.dream = dream;
        layer.type = LayerTypeVideo;
        layer.layerDescription = self.dreamTextField.text;
        layer.layerURL = [NSURL URLWithString:self.youtubeURL];
        [self.layers addObject:layer];
    }
}

#pragma mark - <ConnectionManagerDelegate>

- (void)connectionManager:(ConnectionManager *)manager didCompleteRequestWithReturnedObjects:(NSArray *)objects
{
    if (objects && objects.count == 1 && [objects.firstObject isKindOfClass:[Dream class]]) {
        [self prepareLayersToRequestCreationFromDream:objects.firstObject];
        [self requestNextLayerCreation];
    }
    else if (objects && objects.count > 0 && [objects.firstObject isKindOfClass:[Layer class]]) {
        [self requestNextLayerCreation];
    }
    else {
        [self connectionManager:manager didFailRequestWithError:nil];
    }
}

- (void)requestNextLayerCreation
{
    if (self.layers.count > 0) {
        Layer *layer = self.layers.firstObject;
        [self.layers removeObject:layer];
        [[ConnectionManager defaultManager] requestLayerCreation:layer forDelegate:self];
    }
    else {
        [self stopProgressAnimation];
        [self performSegueWithIdentifier:unwindAfterCreatingDream sender:self];
    }
}

- (void)connectionManager:(ConnectionManager *)manager didFailRequestWithError:(NSError *)error
{
    [self stopProgressAnimation];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.postButton.enabled = ![self.dreamTextField.text isEqualToString:@""] &&
                                    ![self.selectedCategory.text isEqualToString:@""] &&
                                    ![self.selectedSubCategory.text isEqualToString:@""] &&
                                    (self.photoImageView.image || self.youtubeURL);
    });
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

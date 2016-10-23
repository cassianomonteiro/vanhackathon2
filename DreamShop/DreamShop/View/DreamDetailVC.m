//
//  DreamDetailVC.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 23/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "DreamDetailVC.h"
#import <UIImageView+AFRKNetworking.h>
#import "UIImage+Resize.h"
#import "ProductViewNavigationController.h"
#import "ProductViewController.h"
#import "YouTubeHandler.h"

#define SHOP_DOMAIN @"dreamandshop.myshopify.com"
#define API_KEY @"8ada472409a58bacffb8c054e1770894"
#define APP_ID @"8"

@interface DreamDetailVC () <UPCardsCarouselDataSource, UPCardsCarouselDelegate>
@property (nonatomic, strong) BUYClient *client;
@end

@implementation DreamDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.client = [[BUYClient alloc] initWithShopDomain:SHOP_DOMAIN
                                                 apiKey:API_KEY
                                                  appId:APP_ID];
    
    self.title = self.dream.layers.firstObject.layerDescription;
    self.dreamLabel.text = self.dream.layers.firstObject.layerDescription;
    self.categoryLabel.text = self.dream.category;
    self.subCategoryLabel.text = self.dream.subCategory;
    self.categoryImageView.image = [UIImage imageNamed:self.dream.subCategory];
    self.userNameLabel.text = self.dream.user.name;
    [self.userImageView setImageWithURL:self.dream.user.photoURL placeholderImage:nil];
    
    UIColor *labelBannerCollor = [self subCategoriesColors][self.dream.subCategory]?:[UIColor whiteColor];
    UPCardsCarousel *carousel = [[UPCardsCarousel alloc] initWithFrame:CGRectMake(0, 0, self.cardsCarousel.frame.size.width, self.cardsCarousel.frame.size.height)];
    [carousel setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [carousel.labelBanner setBackgroundColor:labelBannerCollor];
    [carousel setLabelFont:[UIFont boldSystemFontOfSize:17.0f]];
    [carousel setLabelTextColor:[UIColor whiteColor]];
    [carousel setDelegate:self];
    [carousel setDataSource:self];
    [self.cardsCarousel addSubview:carousel];
}

#pragma mark - <CardsCarouselDataSource>

- (NSUInteger)numberOfCardsInCarousel:(UPCardsCarousel *)carousel
{
    return self.dream.layers.count;
}

- (UIView*)carousel:(UPCardsCarousel *)carousel viewForCardAtIndex:(NSUInteger)index
{
    return [self createCardViewWithLayer:self.dream.layers[index]];
}

- (NSString*)carousel:(UPCardsCarousel *)carousel labelForCardAtIndex:(NSUInteger)index
{
    return self.dream.layers[index].layerDescription;
}

#pragma mark - <CardsCarouselDelegate>

- (void)carousel:(UPCardsCarousel *)carousel didTouchCardAtIndex:(NSUInteger)index
{
    Layer *layer = self.dream.layers[index];
    
    if ([LayerTypeProduct isEqualToString:layer.type]) {
        
        [self startProgressAnimation];
        
        [self.client getProductById:layer.productId completion:^(BUYProduct * _Nullable product, NSError * _Nullable error) {
            
            if (!error) {
                ProductViewController *productViewController = [[ProductViewController alloc] initWithClient:self.client theme:nil];
                [productViewController loadWithProduct:product completion:^(BOOL success, NSError *error) {
                    if (!error) {
                        [self.navigationController pushViewController:productViewController animated:YES];
                    }
                    [self stopProgressAnimation];
                }];
            }
            else {
                [self stopProgressAnimation];
            }
            
        }];
    }
}

- (void)startProgressAnimation
{
    [self.activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    self.view.alpha = 0.7f;
}

- (void)stopProgressAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        self.view.userInteractionEnabled = YES;
        self.view.alpha = 1.f;
    });
}

#pragma mark - Helpers

- (UIView*)createCardViewWithLayer:(Layer *)layer
{
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
    [cardView setBackgroundColor:[UIColor colorWithRed:180./255. green:180./255. blue:180./255. alpha:1.]];
    [cardView.layer setShadowColor:[UIColor blackColor].CGColor];
    [cardView.layer setShadowOpacity:.5];
    [cardView.layer setShadowOffset:CGSizeMake(0, 0)];
    [cardView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [cardView.layer setBorderWidth:10.];
    [cardView.layer setCornerRadius:4.];
    
    if ([LayerTypeVideo isEqualToString:layer.type]) {
        [self addVideoPlayerToCardView:cardView fromLayer:layer];
    }
    else {
        [self addImageViewToCardView:cardView fromLayer:layer];
    }
    
    return cardView;
}

- (void)addImageViewToCardView:(UIView *)cardView fromLayer:(Layer *)layer
{
    NSURLRequest *request = [NSURLRequest requestWithURL:layer.layerURL];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(cardView.frame, 20, 20)];
    UIImageView __weak *weakImageView = imageView;
    
    [imageView setImageWithURLRequest:request placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  
                                  weakImageView.image = [self squaredImage:image forSize:weakImageView.frame.size];
                                  
                                  if ([LayerTypeProduct isEqualToString:layer.type]) {
                                      [self addShopifyIconToView:weakImageView withPadding:4.f];
                                  }
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  weakImageView.image = nil;
                              }];
    [cardView addSubview:imageView];
}

- (void)addVideoPlayerToCardView:(UIView *)cardView fromLayer:(Layer *)layer
{
    UIView *playerView = [YouTubeHandler youTubePlayerViewWithURL:layer.layerURL inFrame:cardView.frame];
    playerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    [cardView addSubview:playerView];
    [self addShopifyIconToView:cardView withPadding:16.f];
}

- (UIImage *)squaredImage:(UIImage *)image forSize:(CGSize)size
{
    // Resize the image to fit given size
    UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:size interpolationQuality:kCGInterpolationHigh];
    
    // Crop the image to a square
    CGRect croppedRect = CGRectMake((scaledImage.size.width - size.width)/2,
                                    (scaledImage.size.height - size.height)/2,
                                    size.width,
                                    size.height);
    return [scaledImage croppedImage:croppedRect];
}

- (void)addShopifyIconToView:(UIView *)view withPadding:(CGFloat)padding
{
    CGRect iconFrame = CGRectMake(view.frame.size.width - 30.f - padding,
                                  view.frame.size.height - 30.f - padding,
                                  30.f,
                                  30.f);
    
    UIImageView *shopifyImageView = [[UIImageView alloc] initWithFrame:iconFrame];
    shopifyImageView.contentMode = UIViewContentModeScaleAspectFit;
    shopifyImageView.image = [UIImage imageNamed:@"shopify-bag"];
    
    [view addSubview:shopifyImageView];
}

- (NSDictionary<NSString *, UIColor *> *)subCategoriesColors
{
    return @{
             SubCategoryAdventure : [UIColor colorWithRed:196.f/255.f green:118.f/255.f blue:135.f/255.f alpha:1.f],
             SubCategoryBeach : [UIColor colorWithRed:124.f/255.f green:150.f/255.f blue:172.f/255.f alpha:1.f],
             SubCategoryCamping : [UIColor colorWithRed:121.f/255.f green:150.f/255.f blue:109.f/255.f alpha:1.f],
             SubCategoryDesert : [UIColor colorWithRed:243.f/255.f green:185.f/255.f blue:54.f/255.f alpha:1.f],
             SubCategoryOutdoor : [UIColor colorWithRed:105.f/255.f green:155.f/255.f blue:70.f/255.f alpha:1.f],
             SubCategoryPopular : [UIColor colorWithRed:255.f/255.f green:214.f/255.f blue:101.f/255.f alpha:1.f],
             SubCategoryProducts : [UIColor colorWithRed:103.f/255.f green:144.f/255.f blue:159.f/255.f alpha:1.f],
             SubCategoryOthers : [UIColor colorWithRed:119.f/255.f green:119.f/255.f blue:119.f/255.f alpha:1.f],
             SubCategorySports : [UIColor colorWithRed:135.f/255.f green:96.f/255.f blue:95.f/255.f alpha:1.f],
             SubCategoryTravel : [UIColor colorWithRed:97.f/255.f green:91.f/255.f blue:75.f/255.f alpha:1.f],
             SubCategoryTourism : [UIColor colorWithRed:240.f/255.f green:121.f/255.f blue:121.f/255.f alpha:1.f]};
}

@end

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

@interface DreamDetailVC () <UPCardsCarouselDataSource, UPCardsCarouselDelegate>
@end

@implementation DreamDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    return [self createCardViewWithImageURL:self.dream.layers[index].layerURL];
}

- (NSString*)carousel:(UPCardsCarousel *)carousel labelForCardAtIndex:(NSUInteger)index
{
    return self.dream.layers[index].layerDescription;
}

#pragma mark - <CardsCarouselDelegate>

- (void)carousel:(UPCardsCarousel *)carousel didTouchCardAtIndex:(NSUInteger)index
{
    
}

#pragma mark - Helpers

- (UIView*)createCardViewWithImageURL:(NSURL *)imageURL
{
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
    [cardView setBackgroundColor:[UIColor colorWithRed:180./255. green:180./255. blue:180./255. alpha:1.]];
    [cardView.layer setShadowColor:[UIColor blackColor].CGColor];
    [cardView.layer setShadowOpacity:.5];
    [cardView.layer setShadowOffset:CGSizeMake(0, 0)];
    [cardView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [cardView.layer setBorderWidth:10.];
    [cardView.layer setCornerRadius:4.];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(cardView.frame, 20, 20)];
    UIImageView __weak *weakImageView = imageView;
    
    [imageView setImageWithURLRequest:request placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakImageView.image = [self squaredImage:image forSize:weakImageView.frame.size];
    }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakImageView.image = nil;
    }];
    
    [cardView addSubview:imageView];
    return cardView;
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

- (NSDictionary<NSString *, UIColor *> *)subCategoriesColors
{
    return @{SubCategoryBeach : [UIColor colorWithRed:124.f/255.f green:150.f/255.f blue:172.f/255.f alpha:1.f],
             SubCategoryCamping : [UIColor colorWithRed:121.f/255.f green:150.f/255.f blue:109.f/255.f alpha:1.f],
             SubCategoryAdventure : [UIColor colorWithRed:196.f/255.f green:118.f/255.f blue:135.f/255.f alpha:1.f],
             SubCategoryDesert : [UIColor colorWithRed:243.f/255.f green:185.f/255.f blue:54.f/255.f alpha:1.f],
             SubCategoryTourism : [UIColor colorWithRed:240.f/255.f green:121.f/255.f blue:121.f/255.f alpha:1.f]};
}

@end

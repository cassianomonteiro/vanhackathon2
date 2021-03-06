//
//  DreamCell.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "DreamCell.h"
#import <FontAwesomeIconFactory.h>
#import <UIImageView+AFRKNetworking.h>
#import "UIImage+Resize.h"
#import "YouTubeHandler.h"

@implementation DreamCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellID
{
    return @"DreamCell";
}

+ (CGFloat)cellHeight
{
    return 344.f;
}

+ (DreamCell *)dequeueCellFromTableView:(UITableView *)tableView withDream:(Dream *)dream
{
    DreamCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellID]];
    
    if (!cell) {
        cell = [[DreamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self cellID]];
    }
    
    // Release cached images from reused cells, to avoid presenting wrong images from other cells
    cell.dreamImageView.image = nil;
    cell.userImageView.image = nil;
    cell.categoryImageView.image = nil;
    
    [cell.categoryImageView setImage:[UIImage imageNamed:dream.subCategory]];
    
    if (dream.user.photoURL) {
        [cell.userImageView setImageWithURL:dream.user.photoURL];
    }
    else {
        NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory buttonIconFactory];
        factory.size = [self cellHeight];
        cell.userImageView.image = [factory createImageForIcon:NIKFontAwesomeIconUser];
    }
    
    Layer *layer = dream.layers.firstObject;
    cell.playerView.hidden = ![LayerTypeVideo isEqualToString:layer.type];
    cell.dreamImageView.hidden = [LayerTypeVideo isEqualToString:layer.type];
    
    if ([LayerTypeVideo isEqualToString:layer.type]) {
        
        NSString *youtubeID = [YouTubeHandler youTubeIDFromURL:layer.layerURL.absoluteString];
        if (youtubeID) {
            [cell.playerView loadWithVideoId:youtubeID];
            [self checkShopifyIconForDream:dream onView:cell.playerView];
        }
    }
    else {
        NSURLRequest *request = [NSURLRequest requestWithURL:layer.layerURL];
        [cell.dreamImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            cell.dreamImageView.image = [self adjustedImage:image forSize:cell.dreamImageView.frame.size];
            [self checkShopifyIconForDream:dream onView:cell.dreamImageView];
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            cell.dreamImageView.image = nil;
        }];
    }
    
    cell.dreamDescriptionLabel.text = layer.layerDescription;
    cell.userNameLabel.text = dream.user.name;
    cell.categoryLabel.text = dream.category;
    cell.subCategoryLabel.text = dream.subCategory;
    
    return cell;
}

+ (UIImage *)adjustedImage:(UIImage *)image forSize:(CGSize)size
{
    // Resize the image to fit given size
    UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:size interpolationQuality:kCGInterpolationHigh];
    
    // Crop the image to the given size
    CGRect croppedRect = CGRectMake((scaledImage.size.width - size.width)/2,
                                    (scaledImage.size.height - size.height)/2,
                                    size.width,
                                    size.height);
    return [scaledImage croppedImage:croppedRect];
}

+ (void)checkShopifyIconForDream:(Dream *)dream onView:(UIView *)view
{
    NSArray *products = [dream.layers filteredArrayUsingPredicate:
                         [NSPredicate predicateWithFormat:@"type = %@", LayerTypeProduct]];
    
    if (products.count > 0) {
        [self addShopifyIconToView:view];
    }
    else {
        for (UIView *subView in view.subviews) {
            if ([subView isKindOfClass:[UIImageView class]]) {
                [subView removeFromSuperview];
            }
        }
    }
}

+ (void)addShopifyIconToView:(UIView *)view
{
    CGRect iconFrame = CGRectMake(view.frame.size.width - 38.f,
                                  view.frame.size.height - 38.f,
                                  30.f,
                                  30.f);
    
    UIImageView *shopifyImageView = [[UIImageView alloc] initWithFrame:iconFrame];
    shopifyImageView.contentMode = UIViewContentModeScaleAspectFit;
    shopifyImageView.image = [UIImage imageNamed:@"shopify-bag"];
    
    [view addSubview:shopifyImageView];
}

@end

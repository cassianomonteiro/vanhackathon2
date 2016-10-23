//
//  Layer.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *LayerTypePhoto = @"photo";
static NSString *LayerTypeVideo = @"video";
static NSString *LayerTypeProduct = @"product";

@interface Layer : NSObject

@property (nonatomic, strong) NSNumber *layerId;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *layerDescription;
@property (nonatomic, strong) NSURL *layerURL;
@property (nonatomic, strong) NSNumber *productId;

@end

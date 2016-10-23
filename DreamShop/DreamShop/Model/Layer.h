//
//  Layer.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>

static NSString *LayerTypePhoto = @"photo";
static NSString *LayerTypeVideo = @"video";
static NSString *LayerTypeProduct = @"product";

@interface Layer : NSObject

@property (nonatomic, strong) NSNumber *layerId;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *layerDescription;
@property (nonatomic, strong) NSURL *layerURL;
@property (nonatomic, strong) NSNumber *productId;

/**
 * Mapping object for object properties into json attributes
 *
 * @returns RKObjectMapping object
 */
+ (RKObjectMapping *)requestMapping;

/**
 * Mapping object for json attributes into object properties
 *
 * @returns RKObjectMapping object
 */
+ (RKObjectMapping *)responseMapping;

@end

//
//  Dream.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "User.h"
#import "Layer.h"

static NSString *SubCategoryBeach       = @"Beach";
static NSString *SubCategoryCamping     = @"Camping";
static NSString *SubCategoryAdventure   = @"Adventure";
static NSString *SubCategoryDesert      = @"Desert";
static NSString *SubCategoryTourism     = @"Tourism";

@interface Dream : NSObject

@property (nonatomic, strong) NSNumber *dreamId;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *subCategory;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSArray<Layer *> *layers;

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

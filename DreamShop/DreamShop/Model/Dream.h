//
//  Dream.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "User.h"
#import "Layer.h"

static NSString *SubCategoryAdventure   = @"adventure";
static NSString *SubCategoryBeach       = @"beach";
static NSString *SubCategoryCamping     = @"camping";
static NSString *SubCategoryDesert      = @"desert";
static NSString *SubCategoryOthers      = @"others";
static NSString *SubCategoryOutdoor     = @"outdoor";
static NSString *SubCategoryPopular     = @"popular";
static NSString *SubCategoryProducts    = @"products";
static NSString *SubCategorySports      = @"sports";
static NSString *SubCategoryTravel      = @"travel";
static NSString *SubCategoryTourism     = @"tourism";

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

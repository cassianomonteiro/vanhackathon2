//
//  Dream.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "Dream.h"

@implementation Dream

#pragma mark - Mappings

+ (RKObjectMapping *)requestMapping
{
    // User inverse mapping for object property -> json attribute
    return [[self responseMapping] inverseMapping];
}

+ (RKObjectMapping *)responseMapping
{
    // Create mapping object for this class
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    
    // Map json attribute -> object property
    // Not mandatory to map all JSON attributes
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"             : @"dreamId",
                                                  @"category"       : @"category",
                                                  @"subcategory"    : @"subCategory"
                                                  }];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"User" toKeyPath:@"user" withMapping:[User responseMapping]]];
    
    return mapping;
}

@end

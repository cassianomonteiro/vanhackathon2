//
//  Layer.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "Layer.h"

@interface Layer ()
@property (nonatomic, strong) NSString *layerAbsoluteURL;
@end

@implementation Layer

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
                                                  @"id"             : @"layerId",
                                                  @"type"           : @"type",
                                                  @"description"    : @"layerDescription",
                                                  @"url"            : @"layerAbsoluteURL",
                                                  @"product_id"     : @"productId"
                                                  }];
    
    return mapping;
}


#pragma mark - Helpers

- (void)setLayerAbsoluteURL:(NSString *)layerAbsoluteURL
{
    self.layerURL = [NSURL URLWithString:layerAbsoluteURL];
}

- (NSString *)layerAbsoluteURL
{
    return self.layerURL.absoluteString;
}

@end

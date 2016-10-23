//
//  User.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "User.h"

@interface User ()
@property (nonatomic, strong) NSString *photoAbsoluteURL;
@end

@implementation User

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
                                                  @"id"             : @"userId",
                                                  @"name"           : @"name",
                                                  @"firebase_key"   : @"firebaseKey",
                                                  @"photo_url"      : @"photoAbsoluteURL"
                                                  }];
    return mapping;
}

#pragma mark - Helpers

- (void)setPhotoAbsoluteURL:(NSString *)photoAbsoluteURL
{
    self.photoURL = [NSURL URLWithString:photoAbsoluteURL];
}

- (NSString *)photoAbsoluteURL
{
    return self.photoURL.absoluteString;
}

@end

//
//  User.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <RestKit.h>

@interface User : NSObject

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *firebaseKey;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *photoURL;

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

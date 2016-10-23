//
//  FirebaseUploader.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 23/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FirebaseUploader : NSObject

+ (void)uploadImage:(UIImage *)image withCompletionHandler:(void (^)(NSURL *imageURL))completionHandler;

@end

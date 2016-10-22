//
//  AlertControllerFactory.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertControllerFactory : NSObject

+ (UIAlertController *)photoSourceAlertControllerForViewController:(UIViewController *)viewController
                                                     withImageSize:(CGSize)size
                                                 completionHandler:(void(^)(UIImage *image))completionHandler;

@end

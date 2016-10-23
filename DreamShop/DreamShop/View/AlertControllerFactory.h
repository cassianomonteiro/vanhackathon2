//
//  AlertControllerFactory.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertControllerFactory : NSObject

+ (UIAlertController *)textFieldAlertControllerWithTitle:(NSString *)title
                                                 andText:(NSString *)text
                                          andPlaceHolder:(NSString *)placeHolder
                                              actionName:(NSString *)actionName
                                       completionHandler:(void (^)(NSString *text))completionHandler;

+ (UIAlertController *)warningAlertControllerWithTitle:(NSString *)title
                                            andMessage:(NSString *)message;

+ (UIAlertController *)photoSourceAlertControllerForViewController:(UIViewController *)viewController
                                                     withImageSize:(CGSize)size
                                                 completionHandler:(void(^)(UIImage *image))completionHandler;


@end

//
//  SignInDelegate.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInDelegate : NSObject

@property (nonatomic, readonly) BOOL userIsSignedIn;
@property (nonatomic, readonly) NSURL *userPhotoURL;

/**
 * Shows sign-in screen if user not logged in
 * @param viewController: the UIViewController instance to present the sign-in screen
 * @param animated: animate or not the sign-in screen presentation
 */
- (void)checkLoginForViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 * Shows sign-in screen
 * @param viewController: the UIViewController instance to present the sign-in screen
 * @param animated: animate or not the sign-in screen presentation
 */
- (void)showLoginScreenForViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 * Signs out and shows sign-in screen
 * @param viewController: the UIViewController instance to present the sign-in screen
 * @param animated: animate or not the sign-in screen presentation
 */
- (void)signOutForViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

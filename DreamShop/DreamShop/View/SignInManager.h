//
//  SignInDelegate.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"

@class SignInManager;

@protocol SignInManagerDelegate <NSObject>
- (void)signInManagerDidSignIn:(SignInManager *)manager;
- (void)signInManagerDidSignOut:(SignInManager *)manager;
@end

@interface SignInManager : NSObject

@property (nonatomic, weak) id<SignInManagerDelegate> delegate;

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

/**
 * Tries to create an user, if it's not registered yet
 * @param delegate: a ConnectionManagerDelegate instance to receive the response for user creation
 */
- (void)createUserForDelegate:(id<ConnectionManagerDelegate>)delegate;

@end

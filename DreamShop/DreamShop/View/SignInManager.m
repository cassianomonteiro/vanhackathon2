//
//  SignInDelegate.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "SignInManager.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseAuthUI/FirebaseAuthUI.h>
#import <FirebaseGoogleAuthUI/FirebaseGoogleAuthUI.h>
#import <FirebaseFacebookAuthUI/FirebaseFacebookAuthUI.h>
#import <FirebaseTwitterAuthUI/FirebaseTwitterAuthUI.h>

@interface SignInManager () <FIRAuthUIDelegate>
@property (nonatomic) FIRAuth *auth;
@property (nonatomic) FIRAuthUI *authUI;
@end

@implementation SignInManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.auth = [FIRAuth auth];
        self.authUI = [FIRAuthUI defaultAuthUI];
        self.authUI.providers = @[[[FIRFacebookAuthUI alloc] init],
                                  [[FIRGoogleAuthUI alloc] init],
                                  [[FIRTwitterAuthUI alloc] init]];
        self.authUI.delegate = self;
        
    }
    return self;
}

- (BOOL)userIsSignedIn
{
    return (self.auth.currentUser && !self.auth.currentUser.isAnonymous);
}

- (NSURL *)userPhotoURL
{
    return self.auth.currentUser.photoURL;
}

- (void)checkLoginForViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"%@", self.auth.currentUser.uid);
    NSLog(@"%@", self.auth.currentUser.photoURL);
    
    if (self.auth.currentUser) {
        [[ConnectionManager defaultManager] setFirebaseKey:self.auth.currentUser.uid];
        [self.delegate signInManagerDidSignIn:self];
    }
    else {
        [self showLoginScreenForViewController:viewController animated:NO];
    }
}

- (void)showLoginScreenForViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UINavigationController *signInController = [self.authUI authViewController];
    
    // Remove cancel button
    signInController.topViewController.navigationItem.leftBarButtonItem = nil;
    
    [self addSignInLabelToController:signInController.topViewController];
    [self addBackgroundImageToController:signInController.topViewController];
    [viewController presentViewController:signInController animated:animated completion:nil];
}

- (void)signOutForViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // sign out from Firebase
    if ([self.auth signOut:nil]) {
        
        // sign out from all providers (wipes provider tokens too)
        for (id<FIRAuthProviderUI> provider in self.authUI.providers) {
            
            // Surround with try/catch because not all providers are implemented
            @try {
                [provider signOut];
            } @catch (NSException *exception) {
                // Nothing to do
            }
        }
        
        [[ConnectionManager defaultManager] setFirebaseKey:nil];
        [self.delegate signInManagerDidSignOut:self];
        [self showLoginScreenForViewController:viewController animated:animated];
    }
}

- (void)createUserForDelegate:(id<ConnectionManagerDelegate>)delegate
{
    User *user = [[User alloc] init];
    user.name = self.auth.currentUser.displayName;
    user.photoURL = self.auth.currentUser.photoURL;
    user.firebaseKey = self.auth.currentUser.uid;
    [[ConnectionManager defaultManager] requestUserCreation:user forDelegate:delegate];
}

#pragma mark - <FIRAuthUIDelegate>

- (void)authUI:(FIRAuthUI *)authUI didSignInWithUser:(FIRUser *)user error:(NSError *)error
{
    NSLog(@"%@ id: %@", user.isAnonymous ? @"Anonymous" : @"Signedin", user.uid);
    NSLog(@"photoURL: %@", user.photoURL);
    [[ConnectionManager defaultManager] setFirebaseKey:user.uid];
    [self.delegate signInManagerDidSignIn:self];
}

#pragma mark - Helpers

- (void)addSignInLabelToController:(UIViewController *)controller
{
    UIView *buttonsContainerView = controller.view.subviews.firstObject;
    
    UILabel *signInLabel = [[UILabel alloc] init];
    signInLabel.text = @"Sign in";
    signInLabel.textColor = [UIColor whiteColor];
    signInLabel.font = [UIFont systemFontOfSize:44.f];
    signInLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [controller.view addSubview:signInLabel];
    
    NSLayoutConstraint *centerHorizontally = [NSLayoutConstraint constraintWithItem:signInLabel
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:controller.view
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1.0
                                                                           constant:0.0];
    
    NSLayoutConstraint *bottomMargin = [NSLayoutConstraint constraintWithItem:signInLabel
                                                                    attribute:NSLayoutAttributeBottomMargin
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:buttonsContainerView
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:-20.0];
    
    
    [controller.view addConstraint:centerHorizontally];
    [controller.view addConstraint:bottomMargin];
}

- (void)addBackgroundImageToController:(UIViewController *)controller
{
    UIImage *image = [UIImage imageNamed:@"Home"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [controller.view insertSubview:imageView atIndex:0];
    
    NSLayoutConstraint *equalWidths = [NSLayoutConstraint constraintWithItem:imageView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:controller.view
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0
                                                                    constant:0.0];
    
    NSLayoutConstraint *centerHorizontally = [NSLayoutConstraint constraintWithItem:imageView
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:controller.view
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1.0
                                                                           constant:0.0];
    
    NSLayoutConstraint *topMargin = [NSLayoutConstraint constraintWithItem:imageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:controller.view
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:0.0];
    
    NSLayoutConstraint *heightRatio = [NSLayoutConstraint constraintWithItem:imageView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:imageView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:(image.size.height/image.size.width)
                                                                    constant:0.0];
    
    
    [controller.view addConstraint:equalWidths];
    [controller.view addConstraint:centerHorizontally];
    [controller.view addConstraint:topMargin];
    [controller.view addConstraint:heightRatio];
}

@end

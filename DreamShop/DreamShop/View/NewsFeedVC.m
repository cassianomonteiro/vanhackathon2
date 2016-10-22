//
//  NewsFeedVC.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 21/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "NewsFeedVC.h"
#import <FontAwesomeIconFactory.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseAuthUI/FirebaseAuthUI.h>
#import <FirebaseGoogleAuthUI/FirebaseGoogleAuthUI.h>
#import <FirebaseFacebookAuthUI/FirebaseFacebookAuthUI.h>
#import <FirebaseTwitterAuthUI/FirebaseTwitterAuthUI.h>
#import "AlertControllerFactory.h"

@interface NewsFeedVC () <FIRAuthUIDelegate>
@property (nonatomic) FIRAuth *auth;
@property (nonatomic) FIRAuthUI *authUI;
@end

@implementation NewsFeedVC

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.auth = [FIRAuth auth];
    self.authUI = [FIRAuthUI defaultAuthUI];
    self.authUI.providers = @[[[FIRFacebookAuthUI alloc] init],
                              [[FIRGoogleAuthUI alloc] init],
                              [[FIRTwitterAuthUI alloc] init]];
    self.authUI.delegate = self;
    
    if (!self.auth.currentUser) {
        [self showLoginScreeAnimated:NO];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshLoginButton];
}

- (void)refreshLoginButton
{
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory buttonIconFactory];
    factory.size = 24.f;
    
    if (!self.auth.currentUser || self.auth.currentUser.isAnonymous) {
        self.loginButton.image = [factory createImageForIcon:NIKFontAwesomeIconSignIn];
    }
    else {
        self.loginButton.image = [factory createImageForIcon:NIKFontAwesomeIconSignOut];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (void)showLoginScreeAnimated:(BOOL)animated
{
    UINavigationController *controller = [self.authUI authViewController];
    
    // Remove cancel button
    controller.topViewController.navigationItem.leftBarButtonItem = nil;
    
    [self addSignInLabelToController:controller.topViewController];
    [self addBackgroundImageToController:controller.topViewController];
    [self presentViewController:controller animated:animated completion:nil];
}

- (IBAction)loginTapped:(UIBarButtonItem *)sender
{
    if (!self.auth.currentUser) {
        [self showLoginScreeAnimated:YES];
    } else {
        [self signOut];
    }
    
    [self refreshLoginButton];
}

- (IBAction)postTapped:(UIBarButtonItem *)sender
{
    UIAlertController *alertController =
    [AlertControllerFactory photoSourceAlertControllerForViewController:self
                                                          withImageSize:self.photoImageView.frame.size
                                                      completionHandler:^(UIImage *image) {
        self.photoImageView.image = image;
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)authUI:(FIRAuthUI *)authUI didSignInWithUser:(FIRUser *)user error:(NSError *)error
{
    NSLog(@"%@ id: %@", user.isAnonymous ? @"Anonymous" : @"Signedin", user.uid);
}

- (void)signOut
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
        
        [self showLoginScreeAnimated:YES];
    }
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

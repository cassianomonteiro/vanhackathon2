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
    self.authUI.providers = @[[[FIRGoogleAuthUI alloc] init],
                              [[FIRTwitterAuthUI alloc] init]];
    self.authUI.delegate = self;
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

- (IBAction)loginTapped:(UIBarButtonItem *)sender
{
    if (!self.auth.currentUser) {
        UIViewController *controller = [self.authUI authViewController];
        [self presentViewController:controller animated:YES completion:nil];
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
            [provider signOut];
        }
    }
}

@end

//
//  NewsFeedVC.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 21/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "NewsFeedVC.h"
#import <FontAwesomeIconFactory.h>
#import "AlertControllerFactory.h"
#import "SignInDelegate.h"

@interface NewsFeedVC ()
@property (nonatomic, strong) SignInDelegate *signInDelegate;
@end

@implementation NewsFeedVC

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.signInDelegate = [[SignInDelegate alloc] init];
    [self.signInDelegate checkLoginForViewController:self animated:NO];
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
    
    if (self.signInDelegate.userIsSignedIn) {
        self.loginButton.image = [factory createImageForIcon:NIKFontAwesomeIconSignOut];
    }
    else {
        self.loginButton.image = [factory createImageForIcon:NIKFontAwesomeIconSignIn];
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
    if (self.signInDelegate.userIsSignedIn) {
        [self.signInDelegate signOutForViewController:self animated:YES];
    } else {
        [self.signInDelegate showLoginScreenForViewController:self animated:YES];
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

@end

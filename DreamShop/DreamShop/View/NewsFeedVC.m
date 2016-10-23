//
//  NewsFeedVC.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 21/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "NewsFeedVC.h"
#import <FontAwesomeIconFactory.h>
#import <UIImageView+AFRKNetworking.h>
#import "Dream.h"
#import "NewDreamVC.h"
#import "DreamDetailVC.h"
#import "AlertControllerFactory.h"
#import "NewsFeedTVC.h"
#import "SignInManager.h"
#import "ConnectionManager.h"

@interface NewsFeedVC () <ConnectionManagerDelegate, SignInManagerDelegate>
@property (nonatomic, strong) SignInManager *signInManager;
@property (nonatomic, strong) NSArray<Dream *> *dreams;
@property (nonatomic, strong) NewsFeedTVC *newsFeedTVC;
@end

@implementation NewsFeedVC

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.signInManager = [[SignInManager alloc] init];
    self.signInManager.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.dreams = [NSArray array];
    
    // Initialize TableViewController
    self.newsFeedTVC = [[NewsFeedTVC alloc] initWithTableView:self.tableView];
    [self addChildViewController:self.newsFeedTVC];
    [self.newsFeedTVC didMoveToParentViewController:self];
    self.newsFeedTVC.dreams = self.dreams;
    self.newsFeedTVC.signInManager = self.signInManager;
    
    // Initialize Refresh Control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadDreams) forControlEvents:UIControlEventValueChanged];
    [self.newsFeedTVC setRefreshControl:refreshControl];
    
    [self.signInManager checkLoginForViewController:self animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshLoginButton];
    [self.tableView reloadData];
}

- (void)refreshLoginButton
{
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory buttonIconFactory];
    factory.size = 24.f;
    
    if (self.signInManager.userIsSignedIn) {
        self.loginButton.image = [factory createImageForIcon:NIKFontAwesomeIconSignOut];
    }
    else {
        self.loginButton.image = [factory createImageForIcon:NIKFontAwesomeIconSignIn];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[DreamDetailVC class]]) {
        DreamDetailVC *destinationVC = segue.destinationViewController;
        destinationVC.dream = self.dreams[self.tableView.indexPathForSelectedRow.row];
    }
    else if ([segue.destinationViewController isKindOfClass:[NewDreamVC class]]) {
        NewDreamVC *destinationVC = segue.destinationViewController;
        destinationVC.user = self.signInManager.user;
    }
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
}

#pragma mark - Actions

- (IBAction)loginTapped:(UIBarButtonItem *)sender
{
    if (self.signInManager.userIsSignedIn) {
        [self.signInManager signOutForViewController:self animated:YES];
    } else {
        [self.signInManager showLoginScreenForViewController:self animated:YES];
    }
    
    [self refreshLoginButton];
}

#pragma mark - <ConnectionManagerDelegate>

- (void)connectionManager:(ConnectionManager *)manager didCompleteRequestWithReturnedObjects:(NSArray *)objects
{
    if (objects && objects.count == 1 && [objects.firstObject isKindOfClass:[User class]]) {
        // Request all dreams after user creation
        [[ConnectionManager defaultManager] requestDreamsFeedForDelegate:self];
    }
    else if (objects && objects.count > 0 && [objects.firstObject isKindOfClass:[Dream class]]) {
        self.dreams = objects;
        [self stopProgressAnimation];
    }
    else {
        [self connectionManager:manager didFailRequestWithError:nil];
    }
}

- (void)connectionManager:(ConnectionManager *)manager didFailRequestWithError:(NSError *)error
{
    self.dreams = [NSArray array];
    [self stopProgressAnimation];
}

#pragma mark - <SignInManagerDelegate>

- (void)signInManagerDidSignIn:(id)manager
{
    [self loadDreams];
}

- (void)signInManagerDidSignOut:(id)manager
{
    self.dreams = [NSArray array];
}

#pragma mark - Helpers

- (void)loadDreams
{
    [self startProgressAnimation];

    // Create user, if it doesn't exist yet
    [self.signInManager createUserForDelegate:self];
}

- (void)setDreams:(NSArray<Dream *> *)dreams
{
    _dreams = dreams;
    self.newsFeedTVC.dreams = dreams;
}

- (void)startProgressAnimation
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.activityIndicator startAnimating];
}

- (void)stopProgressAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.activityIndicator stopAnimating];
        [self.newsFeedTVC.refreshControl endRefreshing];
        [self.tableView reloadData];
    });
}

@end

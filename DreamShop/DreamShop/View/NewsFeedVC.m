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
#import "DreamDetailVC.h"
#import "AlertControllerFactory.h"
#import "SignInManager.h"
#import "DreamCell.h"
#import "SimpleImageCell.h"
#import "ConnectionManager.h"

@interface NewsFeedVC () <UITableViewDataSource, UITableViewDelegate, ConnectionManagerDelegate, SignInManagerDelegate>
@property (nonatomic, strong) SignInManager *signInManager;
@property (nonatomic, strong) NSMutableArray<Dream *> *dreams;
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
    self.dreams = [NSMutableArray array];
    
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

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: // Section "What is your dream?"
            return 1;
            break;
        case 1: // Section with dreams news need
            return self.dreams.count;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return [self tableView:tableView userDreamCellForRowAtIndexPath:indexPath];
            break;
        case 1:
            return [DreamCell dequeueCellFromTableView:tableView withDream:self.dreams[indexPath.row]];
            break;
        default:
            return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView userDreamCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimpleImageCell *cell = [tableView dequeueReusableCellWithIdentifier:[SimpleImageCell cellID]];
    
    if (!cell) {
        cell = [[SimpleImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[SimpleImageCell cellID]];
    }
    
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory buttonIconFactory];
    factory.size = [SimpleImageCell cellHeight];
    UIImage *userImage = [factory createImageForIcon:NIKFontAwesomeIconUser];
    
    cell.cellImageView.image = nil;
    if (self.signInManager.userPhotoURL) {
        [cell.cellImageView setImageWithURL:self.signInManager.userPhotoURL placeholderImage:userImage];
    }
    else {
        cell.cellImageView.image = userImage;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4.f;
            break;
        case 1:
            return 1.f;
        default:
            return 0.f;
            break;
    }
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 77.f;
            break;
        case 1:
            return [DreamCell cellHeight];
        default:
            return 0;
            break;
    }
}

#pragma mark - <ConnectionManagerDelegate>

- (void)connectionManager:(ConnectionManager *)manager didCompleteRequestWithReturnedObjects:(NSArray *)objects
{
    if (objects && objects.count == 1 && [objects.firstObject isKindOfClass:[User class]]) {
        // Request all dreams after user creation
        [[ConnectionManager defaultManager] requestAllDreamsForDelegate:self];
    }
    else if (objects && objects.count > 0 && [objects.firstObject isKindOfClass:[Dream class]]) {
        self.dreams = [objects mutableCopy];
        [self stopProgressAnimation];
    }
    else {
        [self connectionManager:manager didFailRequestWithError:nil];
    }
}

- (void)connectionManager:(ConnectionManager *)manager didFailRequestWithError:(NSError *)error
{
    self.dreams = [NSMutableArray array];
    [self stopProgressAnimation];
}

#pragma mark - <SignInManagerDelegate>

- (void)signInManagerDidSignIn:(id)manager
{
    [self loadDreams];
}

- (void)signInManagerDidSignOut:(id)manager
{
    self.dreams = [NSMutableArray array];
}

#pragma mark - Helpers

- (void)loadDreams
{
//    [self startProgressAnimation];
//    
//    // Create user, if it doesn't exist yet
//    [self.signInManager createUserForDelegate:self];
    
    
//     Mock dreams
        NSArray<NSString *> *subCategories = @[SubCategoryBeach,
                                               SubCategoryDesert,
                                               SubCategoryCamping,
                                               SubCategoryTourism,
                                               SubCategoryAdventure];
    
        self.dreams = [NSMutableArray arrayWithCapacity:5];
    
        for (int i = 0; i<5; i++) {
            Dream *dream = [[Dream alloc] init];
            dream.dreamId = @(i);
            dream.category = [NSString stringWithFormat:@"Travel %d", i];
            dream.subCategory = subCategories[i];
    
            NSMutableArray *layers = [NSMutableArray arrayWithCapacity:3];
            for (int j = 0; j < 3; j++) {
                Layer *layer = [[Layer alloc] init];
                layer.type = LayerTypePhoto;
                layer.layerDescription = [NSString stringWithFormat:@"Skydiving %d", j];
                layer.layerURL = [NSURL URLWithString:@"http://www.dreamify.com/Dreamify/skydiving_image.png"];
                [layers addObject:layer];
            }
            
            Layer *layer = [[Layer alloc] init];
            layer.type = LayerTypePhoto;
            layer.layerDescription = [NSString stringWithFormat:@"Skydiving %d", i];
            layer.layerURL = [NSURL URLWithString:@"http://www.dreamify.com/Dreamify/skydiving_image.png"];
    
            User *user = [[User alloc] init];
            user.photoURL = self.signInManager.userPhotoURL;
            user.name = @"Cassiano Monteiro";
    
            dream.layers = layers;
            dream.user = user;
            [self.dreams addObject:dream];
        }
}

- (void)startProgressAnimation
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.activityIndicator startAnimating];
    self.tableView.userInteractionEnabled = NO;
}

- (void)stopProgressAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.activityIndicator stopAnimating];
        self.tableView.userInteractionEnabled = YES;
        [self.tableView reloadData];
    });
}

@end

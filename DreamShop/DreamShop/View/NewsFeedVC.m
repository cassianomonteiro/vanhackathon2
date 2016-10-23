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
#import "AlertControllerFactory.h"
#import "SignInDelegate.h"
#import "DreamCell.h"
#import "SimpleImageCell.h"

@interface NewsFeedVC () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) SignInDelegate *signInDelegate;
@property (nonatomic, strong) NSMutableArray<Dream *> *dreams;
@end

@implementation NewsFeedVC

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.signInDelegate = [[SignInDelegate alloc] init];
    [self.signInDelegate checkLoginForViewController:self animated:NO];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // Mock dreams
    NSArray<NSString *> *subCategories = @[SubCategoryBeach,
                                           SubCategoryDesert,
                                           SubCategoryCamping,
                                           SubCategoryTourism,
                                           SubCategoryAdventure];
    
    self.dreams = [NSMutableArray arrayWithCapacity:5];
    
    for (int i = 0; i<5; i++) {
        Dream *dream = [[Dream alloc] init];
        dream.dreamId = @(i);
        dream.category = @"Travel";
        dream.subCategory = subCategories[i];
        
        Layer *layer = [[Layer alloc] init];
        layer.type = LayerTypePhoto;
        layer.layerDescription = @"Skydiving";
        layer.layerURL = [NSURL URLWithString:@"http://www.dreamify.com/Dreamify/skydiving_image.png"];
        
        User *user = [[User alloc] init];
        user.photoURL = self.signInDelegate.userPhotoURL;
        user.name = @"Cassiano Monteiro";
        
        dream.layers = @[layer];
        dream.user = user;
        [self.dreams addObject:dream];
    }
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
    if (self.signInDelegate.userPhotoURL) {
        [cell.cellImageView setImageWithURL:self.signInDelegate.userPhotoURL placeholderImage:userImage];
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

@end

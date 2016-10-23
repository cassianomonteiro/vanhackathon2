//
//  SearchProductsVC.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "SearchProductsVC.h"
#import <Buy/Buy.h>
#import <UIImageView+AFRKNetworking.h>
#import "SimpleImageCell.h"
#import "ProductViewNavigationController.h"
#import "ProductViewController.h"

#define SHOP_DOMAIN @"dreamandshop.myshopify.com"
#define API_KEY @"8ada472409a58bacffb8c054e1770894"
#define APP_ID @"8"

@interface SearchProductsVC () <UISearchResultsUpdating>
@property (nonatomic, strong) BUYClient *client;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSArray *filteredProducts;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation SearchProductsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.products = @[];
    self.filteredProducts = self.products;
    self.activityIndicator = [self createActivityIndicator];
    self.searchController = [self createSearchController];
    self.client = [[BUYClient alloc] initWithShopDomain:SHOP_DOMAIN
                                                 apiKey:API_KEY
                                                  appId:APP_ID];
    [self loadProducts];
}

#pragma mark - Actions

- (IBAction)cancelTapped:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.selectedProduct = self.products[self.tableView.indexPathForSelectedRow.row];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimpleImageCell *cell = [tableView dequeueReusableCellWithIdentifier:[SimpleImageCell cellID]];
    
    if (!cell) {
        cell = [[SimpleImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[SimpleImageCell cellID]];
    }
    
    BUYProduct *product = self.filteredProducts[indexPath.row];
    
    cell.cellTitle.text = product.title;
    cell.cellImageView.image = nil;
    
    if (product.images && product.images.count > 0) {
        BUYImageLink *imageLink = product.images.firstObject;
        [cell.cellImageView setImageWithURL:[imageLink imageURLWithSize:BUYImageURLSize100x100]];
    }
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    BUYProduct *product = self.filteredProducts[indexPath.row];
    
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:self.activityIndicator];
    self.tableView.userInteractionEnabled = NO;
    
    ProductViewController *productViewController = [[ProductViewController alloc] initWithClient:self.client theme:nil];
    [productViewController loadWithProduct:product completion:^(BOOL success, NSError *error) {
        if (!error ) {
            [self.navigationController pushViewController:productViewController animated:YES];
        }
        [self.activityIndicator stopAnimating];
        self.tableView.userInteractionEnabled = YES;
    }];
}

#pragma mark - Helpers

- (void)loadProducts
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.activityIndicator startAnimating];
    [self.view bringSubviewToFront:self.activityIndicator];
    self.tableView.userInteractionEnabled = NO;
    
    [self.client getProductsPage:1 completion:^(NSArray *products, NSUInteger page, BOOL reachedEnd, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.activityIndicator stopAnimating];
        self.tableView.userInteractionEnabled = YES;
        if (error == nil && products) {
            self.products = products;
            self.filteredProducts = products;
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error fetching products: %@", error);
        }
    }];
}

- (UIActivityIndicatorView *)createActivityIndicator
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityIndicator.color = [UIColor blackColor];
    [self.view addSubview:activityIndicator];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    return activityIndicator;
}

- (UISearchController *)createSearchController
{
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    self.tableView.tableHeaderView = searchController.searchBar;
    self.definesPresentationContext = YES;
    
    return searchController;
}

#pragma mark - <UISearchResultsUpdating>

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *filterText = searchController.searchBar.text;
    
    if (filterText && filterText.length > 0) {
        self.filteredProducts = [self.products filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", filterText]];
    }
    else {
        self.filteredProducts = self.products;
    }
    
    [self.tableView reloadData];
}

@end

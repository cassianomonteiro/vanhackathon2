//
//  NewsFeedVC.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 21/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsFeedVC : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;

- (IBAction)loginTapped:(UIBarButtonItem *)sender;

@end
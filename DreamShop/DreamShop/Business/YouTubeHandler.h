//
//  YouTubeHandler.h
//  DreamShop
//
//  Created by Cassiano Monteiro on 23/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YouTubeHandler : NSObject

+ (UIView *)youTubePlayerViewWithURL:(NSURL *)url inFrame:(CGRect)frame;
+ (NSString *)youTubeIDFromURL:(NSString *)url;

@end

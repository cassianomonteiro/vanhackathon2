//
//  YouTubeHandler.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 23/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "YouTubeHandler.h"
#import <YTPlayerView.h>

@implementation YouTubeHandler

+ (UIView *)youTubePlayerViewWithURL:(NSURL *)url inFrame:(CGRect)frame
{
    NSString *youTubeID = [self youTubeIDFromURL:url.absoluteString];
    
    if (!youTubeID) {
        return nil;
    }
    
    YTPlayerView *playerView = [[YTPlayerView alloc] initWithFrame:frame];
    [playerView loadWithVideoId:youTubeID];
    return playerView;
}

+ (NSString *)youTubeIDFromURL:(NSString *)url
{
    
    NSString *pattern = @"(?:(?:\\.be\\/|embed\\/|v\\/|\\?v=|\\&v=|\\/videos\\/)|(?:[\\w+]+#\\w\\/\\w(?:\\/[\\w]+)?\\/\\w\\/))([\\w-_]+)";
    
    NSRegularExpression *regex  = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:url
                                                    options:0
                                                      range:NSMakeRange(0, [url length])];
    if (match) {
        NSRange videoIDRange             = [match rangeAtIndex:1];
        NSString *substringForFirstMatch = [url substringWithRange:videoIDRange];
        
        return  substringForFirstMatch;
    }
    else {
        return nil;
    }
}

@end

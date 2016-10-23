//
//  FirebaseUploader.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 23/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "FirebaseUploader.h"
#import <FirebaseStorage/FirebaseStorage.h>

@implementation FirebaseUploader

+ (void)uploadImage:(UIImage *)image withCompletionHandler:(void (^)(NSURL *))completionHandler
{
    // Get root storage reference
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage referenceForURL:@"gs://vanhackathon-1d4be.appspot.com"];
    
    // Data in memory
    NSData *data = UIImagePNGRepresentation(image);
    
    // Create a reference to the file to be uploaded
    NSString *fileName = [NSString stringWithFormat:@"%f.png", [NSDate date].timeIntervalSinceReferenceDate];
    FIRStorageReference *fileRef = [storageRef child:fileName];
    
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/png";
    
    // Upload the file to the path "images/rivers.jpg"
    [fileRef putData:data metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error != nil) {
            completionHandler(nil);
        } else {
            completionHandler(metadata.downloadURL);
        }
    }];
}

@end

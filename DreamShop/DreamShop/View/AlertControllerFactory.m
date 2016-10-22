//
//  AlertControllerFactory.m
//  DreamShop
//
//  Created by Cassiano Monteiro on 22/10/16.
//  Copyright © 2016 Cassiano Monteiro. All rights reserved.
//

#import "AlertControllerFactory.h"
#import "UIImage+Resize.h"

@interface AlertControllerFactory() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIViewController *presentingViewController;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) void (^completionHandler)(UIImage *);
@end

@implementation AlertControllerFactory

static AlertControllerFactory *_sharedInstance;

+ (AlertControllerFactory *)defaultFactory
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AlertControllerFactory alloc] init];
    });
    
    return _sharedInstance;
}

+ (UIAlertController *)photoSourceAlertControllerForViewController:(UIViewController *)viewController
                                                     withImageSize:(CGSize)size
                                                 completionHandler:(void (^)(UIImage *))completionHandler
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Photo Library"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
            [self getPhotoFromSource:UIImagePickerControllerSourceTypePhotoLibrary
                   forViewController:viewController
                       withImageSize:size
                   completionHandler:completionHandler];
    }];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Take Photo"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
            [self getPhotoFromSource:UIImagePickerControllerSourceTypeCamera
                   forViewController:viewController
                       withImageSize:size
                   completionHandler:completionHandler];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:libraryAction];
    [alertController addAction:cameraAction];
    [alertController addAction:cancelAction];
    
    return alertController;
}

+ (void)getPhotoFromSource:(UIImagePickerControllerSourceType)sourceType
         forViewController:(UIViewController *)viewController
             withImageSize:(CGSize)imageSize
         completionHandler:(void (^)(UIImage *))completionHandler
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = sourceType;
    imagePickerController.editing = YES;
    imagePickerController.delegate = [self defaultFactory];
    
    [self defaultFactory].presentingViewController = viewController;
    [self defaultFactory].imageSize = imageSize;
    [self defaultFactory].completionHandler = completionHandler;
    [viewController presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Resize the image to fit given size
    UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:self.imageSize interpolationQuality:kCGInterpolationHigh];
    
    // Crop the image to a square
    CGRect croppedRect = CGRectMake((scaledImage.size.width - self.imageSize.width)/2,
                                    (scaledImage.size.height - self.imageSize.height)/2,
                                    self.imageSize.width,
                                    self.imageSize.height);
    UIImage *croppedImage = [scaledImage croppedImage:croppedRect];
    
    // Return the photo to viewController and dismiss
    self.completionHandler(croppedImage);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

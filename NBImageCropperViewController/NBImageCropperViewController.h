//
//  NBImageCropperViewController.h
//  NBCropperImageViewController
//
//  Created by liuzuopeng01 on 12/6/15.
//  Copyright © 2015 liuzuopeng01. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NBImageCropperViewController;

@protocol NBImageCropperViewControllerDelegate
<
NSObject
>
@optional
- (void)NBImageCropperViewController:(NBImageCropperViewController *)cropperViewController didFinishWithCroppedImage:(UIImage *)croppedImage;
- (void)NBImageCropperDidCancel:(NBImageCropperViewController *)cropperViewController;

@end



@interface NBImageCropperViewController : UIViewController

@property (nonatomic, weak) id <NBImageCropperViewControllerDelegate> imageCropperDelegate;

- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

@end

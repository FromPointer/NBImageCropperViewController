//
//  ViewController.m
//  NBCropperImageViewController
//
//  Created by liuzuopeng01 on 12/6/15.
//  Copyright © 2015 liuzuopeng01. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ViewController.h"
#import "NBImageCropperViewController.h"


@interface ViewController ()
<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
NBImageCropperViewControllerDelegate
>

@property (weak, nonatomic) IBOutlet UIImageView *editedImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.editedImageView.userInteractionEnabled = YES;
    [self.editedImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.editedImageView setClipsToBounds:YES];
    self.editedImageView.layer.cornerRadius = 100.f;
}


- (IBAction)didTapCropImageAction:(UITapGestureRecognizer *)sender {
    NSLog(@"didTapCropImageAction:");
    
    if ([self _isSupportPhotoLibrary]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        imagePickerController.mediaTypes = mediaTypes;
        imagePickerController.delegate = self;
        
        [self presentViewController:imagePickerController
                           animated:YES
                         completion:^(void){
                             NSLog(@"Picker View Controller is presented");
                         }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - delegate for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    __weak typeof(self) wself = self;
    [picker dismissViewControllerAnimated:YES completion:^{
         UIImage *portraitImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        [wself beginUsingImageCropperForImage:portraitImage];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - NBImageCropperViewController

- (void)beginUsingImageCropperForImage:(UIImage *)image {
    NBImageCropperViewController *imageCropper = [[NBImageCropperViewController alloc] initWithImage:image cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
    imageCropper.imageCropperDelegate = self;
    [self presentViewController:imageCropper animated:YES completion:^{
    }];
}


- (void)NBImageCropperDidCancel:(NBImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)NBImageCropperViewController:(NBImageCropperViewController *)cropperViewController didFinishWithCroppedImage:(UIImage *)croppedImage {
    __weak typeof(self) wself = self;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        wself.editedImageView.image = croppedImage;
    }];
}


#pragma mark - private method

- (BOOL)_isSupportPhotoLibrary {
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

@end

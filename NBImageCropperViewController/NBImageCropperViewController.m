//
//  NBImageCropperViewController.m
//  NBCropperImageViewController
//
//  Created by liuzuopeng01 on 12/6/15.
//  Copyright © 2015 liuzuopeng01. All rights reserved.
//

#import "NBImageCropperViewController.h"


#define SCALE_FRAME_Y    (100.0f)
#define BOUNDCE_DURATION (0.3f)


@interface NBImageCropperViewController ()

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *croppedImage;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIImageView *croppedImageView;

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *ratioView;

@property (nonatomic, assign) CGRect cropFrame;
@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect largeFrame;
@property (nonatomic, assign) CGFloat limitRatio;

@property (nonatomic, assign) CGRect latestFrame;

@end


@implementation NBImageCropperViewController

- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio {
    self = [super init];
    if (self) {
        self.cropFrame = cropFrame;
        self.limitRatio = limitRatio;
        self.originalImage = [self fixOrientation:originalImage];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [self initBaseControl];
}


- (void)initView {
    self.view.backgroundColor = [UIColor blackColor];

    [self.view addSubview:self.croppedImageView];
    
    // scale to fit the screen
    CGFloat oriWidth = self.cropFrame.size.width;
    CGFloat oriHeight = self.originalImage.size.height * (oriWidth / self.originalImage.size.width);
    CGFloat oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2;
    CGFloat oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    self.latestFrame = self.oldFrame;
    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    
    self.croppedImageView.frame = self.oldFrame;

    [self.view addSubview:self.overlayView];
    [self.view addSubview:self.ratioView];
    
    [self addGestureRecognizers];
    [self overlayClipping];
}


- (void)initBaseControl {
    [self.view addSubview:self.confirmButton];
    [self.view addSubview:self.cancelButton];
}


- (void)dealloc {
    self.originalImage = nil;
    self.croppedImage = nil;
    self.croppedImageView = nil;
    self.overlayView = nil;
    self.ratioView = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}


#pragma mark - getter/setter property

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100.0f, self.view.frame.size.height - 50.0f, 100, 50)];
        _confirmButton.backgroundColor = [UIColor blackColor];
        _confirmButton.titleLabel.textColor = [UIColor whiteColor];
        [_confirmButton setTitle:@"OK" forState:UIControlStateNormal];
        [_confirmButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [_confirmButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        _confirmButton.titleLabel.textColor = [UIColor whiteColor];
        [_confirmButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_confirmButton.titleLabel setNumberOfLines:0];
        [_confirmButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        [_confirmButton addTarget:self action:@selector(didTapConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return (_confirmButton);
}


- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50.0f, 100, 50)];
        _cancelButton.backgroundColor = [UIColor blackColor];
        _cancelButton.titleLabel.textColor = [UIColor whiteColor];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [_cancelButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_cancelButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_cancelButton.titleLabel setNumberOfLines:0];
        [_cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        [_cancelButton addTarget:self action:@selector(didTapCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return (_cancelButton);
}


- (UIImageView *)croppedImageView {
    if (!_croppedImageView) {
        _croppedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [_croppedImageView setMultipleTouchEnabled:YES];
        [_croppedImageView setUserInteractionEnabled:YES];
        [_croppedImageView setImage:self.originalImage];
    }
    
    return (_croppedImageView);
}


- (UIView *)overlayView {
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        _overlayView.alpha = .5f;
        _overlayView.backgroundColor = [UIColor blackColor];
        _overlayView.userInteractionEnabled = NO;
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return (_overlayView);
}


- (UIView *)ratioView {
    if (!_ratioView) {
        _ratioView = [[UIView alloc] initWithFrame:self.cropFrame];
        _ratioView.layer.borderColor = [UIColor yellowColor].CGColor;
        _ratioView.layer.borderWidth = 1.0f;
        _ratioView.autoresizingMask = UIViewAutoresizingNone;
    }
    return (_ratioView);
}


#pragma mark - event for button

- (void)didTapCancelButton:(id)sender {
    if (self.imageCropperDelegate && [self.imageCropperDelegate conformsToProtocol:@protocol(NBImageCropperViewControllerDelegate)] && [self.imageCropperDelegate respondsToSelector:@selector(NBImageCropperDidCancel:)]) {
        [self.imageCropperDelegate NBImageCropperDidCancel:self];
    }
}

- (void)didTapConfirmButton:(id)sender {
    if (self.imageCropperDelegate && [self.imageCropperDelegate conformsToProtocol:@protocol(NBImageCropperViewControllerDelegate)] && [self.imageCropperDelegate respondsToSelector:@selector(NBImageCropperViewController:didFinishWithCroppedImage:)]) {
        [self.imageCropperDelegate NBImageCropperViewController:self didFinishWithCroppedImage:[self getSubImage]];
    }
}


- (void)overlayClipping {
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.ratioView.frame.origin.x,
                                        self.overlayView.frame.size.height));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(
                                        self.ratioView.frame.origin.x + self.ratioView.frame.size.width,
                                        0,
                                        self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width,
                                        self.overlayView.frame.size.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.overlayView.frame.size.width,
                                        self.ratioView.frame.origin.y));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        self.ratioView.frame.origin.y + self.ratioView.frame.size.height,
                                        self.overlayView.frame.size.width,
                                        self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}


#pragma mark - add recognizer

- (void)addGestureRecognizers {
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    // add pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}


#pragma mark - event for gesture
// pinch gesture handler
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.croppedImageView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    } else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.croppedImageView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            wself.croppedImageView.frame = newFrame;
            wself.latestFrame = newFrame;
        }];
    }
}


// pan gesture handler
- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView *view = self.croppedImageView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.croppedImageView.frame.size.width / self.cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.croppedImageView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            wself.croppedImageView.frame = newFrame;
            wself.latestFrame = newFrame;
        }];
    }
}


- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width / 2, newFrame.origin.y + newFrame.size.height / 2);
    
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    
    newFrame.origin.x = oriCenter.x - newFrame.size.width / 2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height / 2;
    
    return newFrame;
}


- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width) newFrame.origin.x = self.cropFrame.size.width - newFrame.size.width;
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y) newFrame.origin.y = self.cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.croppedImageView.frame.size.width > self.croppedImageView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

- (UIImage *)getSubImage{
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / self.originalImage.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.height / scaleRatio;
    if (self.latestFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH; h = newH;
    }
    if (self.latestFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newH; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    return smallImage;
}


- (UIImage *)fixOrientation:(UIImage *)srcImg {
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgImg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgImg];
    CGContextRelease(ctx);
    CGImageRelease(cgImg);
    
    return img;
}

@end

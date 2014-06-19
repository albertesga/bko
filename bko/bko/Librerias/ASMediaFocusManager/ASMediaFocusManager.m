//
//  ASMediaFocusManager.m
//  ASMediaFocusManager
//
//  Created by Philippe Converset on 11/12/12.
//  Copyright (c) 2012 AutreSphere. All rights reserved.
//

#import "ASMediaFocusManager.h"
#import "ASMediaFocusController.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kAnimateElasticSizeRatio = 0.03;
static CGFloat const kAnimateElasticDurationRatio = 0.6;
static CGFloat const kAnimateElasticSecondMoveSizeRatio = 0.5;
static CGFloat const kAnimateElasticThirdMoveSizeRatio = 0.2;
static CGFloat const kAnimationDuration = 0.5;

@interface ASMediaFocusManager ()
// The media view being focused.
@property (nonatomic, strong) UIView *mediaView;
@property (nonatomic, strong) ASMediaFocusController *focusViewController;
@property (nonatomic) BOOL isZooming;
@property (nonatomic) BOOL isPanoramic;
@end

@implementation ASMediaFocusManager

- (UIImage *)decodedImageWithImage:(UIImage *)image
{
   if (image.images) {
      // Do not decode animated images
      return image;
   }
   
   CGImageRef imageRef = image.CGImage;
   CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
   CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
   
   CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
   CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
   
   int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
   BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                       infoMask == kCGImageAlphaNoneSkipFirst ||
                       infoMask == kCGImageAlphaNoneSkipLast);
   
   if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
      // Unset the old alpha info.
      bitmapInfo &= ~kCGBitmapAlphaInfoMask;
      
      // Set noneSkipFirst.
      bitmapInfo |= kCGImageAlphaNoneSkipFirst;
   }
   // Some PNGs tell us they have alpha but only 3 components. Odd.
   else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
      // Unset the old alpha info.
      bitmapInfo &= ~kCGBitmapAlphaInfoMask;
      bitmapInfo |= kCGImageAlphaPremultipliedFirst;
   }
   
   // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
   CGContextRef context = CGBitmapContextCreate(NULL,
                                                imageSize.width,
                                                imageSize.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                colorSpace,
                                                bitmapInfo);
   CGColorSpaceRelease(colorSpace);
   
   // If failed, return undecompressed image
   if (!context) return image;
   
   CGContextDrawImage(context, imageRect, imageRef);
   CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
   
   CGContextRelease(context);
   
   UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
   CGImageRelease(decompressedImageRef);
   return decompressedImage;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.animationDuration = kAnimationDuration;
        self.backgroundColor = [UIColor blackColor];
        self.elasticAnimation = YES;
        self.zoomEnabled = YES;
        self.isZooming = YES;
        self.gestureDisabledDuringZooming = NO;
        self.isDefocusingWithTap = NO;
    }
    
    return self;
}

- (void)installOnViews:(NSArray *)views
{
    for(UIView *view in views)
    {
        [self installOnView:view];
    }
}

- (void)installOnView:(UIView *)view
{
    UITapGestureRecognizer *tapGesture;
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFocusGesture:)];
    [view addGestureRecognizer:tapGesture];
    view.userInteractionEnabled = YES;
}

- (void)installDefocusActionOnFocusViewController:(ASMediaFocusController *)focusViewController
{
    // We need the view to be loaded.
    if(focusViewController.view)
    {
        if(self.isDefocusingWithTap)
        {
            UITapGestureRecognizer *tapGesture;

            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDefocusGesture:)];
            [tapGesture requireGestureRecognizerToFail:focusViewController.doubleTapGesture];
            [focusViewController.view addGestureRecognizer:tapGesture];
        }
        else
        {
            [self setupAccessoryViewOnFocusViewController:focusViewController];
        }
    }
}

- (ASMediaFocusController *)focusViewControllerForView:(UIView *)mediaView
{
    ASMediaFocusController *viewController;
    UIImage *image;
    UIImageView *imageView;
    
    imageView = [self.delegate mediaFocusManager:self imageViewForView:mediaView];
    image = imageView.image;
    if((imageView == nil) || (image == nil))
        return nil;

    viewController = [[ASMediaFocusController alloc] initWithNibName:nil bundle:nil];
    [self installDefocusActionOnFocusViewController:viewController];
    viewController.titleLabel.text = [self.delegate mediaFocusManager:self titleForView:mediaView];
    viewController.mainImageView.image = image;
    if(image.size.height<image.size.width){
        _isPanoramic = TRUE;
    }
    viewController.mainImageView.contentMode = imageView.contentMode;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url;
        NSData *data;
        NSError *error = nil;
        
        url = [self.delegate mediaFocusManager:self mediaURLForView:mediaView];
        data = [NSData dataWithContentsOfURL:url options:0 error:&error];
        
        if(error != nil)
        {
            NSLog(@"Warning: Unable to load image at %@. %@", url, error);
        }
        else
        {
            UIImage *image;

            image = [[UIImage alloc] initWithData:data];
            image = [self decodedImageWithImage:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                viewController.mainImageView.image = image;
            });
        }
    });

    return viewController;
}

- (CGRect)rectInsetsForRect:(CGRect)frame ratio:(CGFloat)ratio
{
    CGFloat dx;
    CGFloat dy;
    ratio = 0;
    dx = frame.size.width*ratio;
    dy = frame.size.height*ratio;
    
    return CGRectIntegral(CGRectInset(frame, dx, dy));
}

- (void)installZoomView
{
    if(self.zoomEnabled)
    {
        [self.focusViewController installZoomView];
    }
}

- (void)uninstallZoomView
{
    if(self.zoomEnabled)
    {
        [self.focusViewController uninstallZoomView];
    }
    [self.focusViewController pinAccessoryView];
}

- (void)setupAccessoryViewOnFocusViewController:(ASMediaFocusController *)focusViewController
{
    UIButton *doneButton;
    
    doneButton = [[UIButton alloc] initWithFrame:CGRectMake(250, 400, 30, 30)];
    [doneButton setBackgroundImage:[UIImage imageNamed:@"button_CERRAR.png"] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(handleDefocusGesture:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton sizeToFit];
    doneButton.frame = CGRectInset(doneButton.frame, -20, -4);
    doneButton.center = CGPointMake(focusViewController.accessoryView.bounds.size.width - doneButton.bounds.size.width/2 - 10, doneButton.bounds.size.height/2 + 10);
    doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    CGRect newFrame = doneButton.frame;
    
    newFrame.size.width = 30;
    newFrame.size.height = 30;
    [doneButton setFrame:newFrame];
    [focusViewController.accessoryView addSubview:doneButton];
}

- (CGSize)sizeThatFitsInSize:(CGSize)boundingSize initialSize:(CGSize)initialSize
{
	// Compute the final size that fits in boundingSize in order to keep aspect ratio from initialSize.
	CGSize fittingSize;
	
    CGFloat widthRatio;
    CGFloat heightRatio;
    
    
    widthRatio = boundingSize.width / initialSize.width;
    heightRatio = boundingSize.height / initialSize.height;
    
    if (widthRatio < heightRatio)
    {
        fittingSize = CGSizeMake(boundingSize.width, floorf(initialSize.height * widthRatio));
    }
    else
    {
        fittingSize = CGSizeMake(floorf(initialSize.width * heightRatio), boundingSize.height);
    }
    
	return fittingSize;
}

#pragma mark - Gestures
- (void)handleFocusGesture:(UIGestureRecognizer *)gesture
{
    UIViewController *parentViewController;
    ASMediaFocusController *focusViewController;
    CGPoint center;
    UIView *mediaView;
    UIImageView *imageView;
    NSTimeInterval duration;
    CGRect finalImageFrame;
    __block CGRect untransformedFinalImageFrame;
    
    mediaView = gesture.view;
    focusViewController = [self focusViewControllerForView:mediaView];
    if(focusViewController == nil)
        return;
    
    self.focusViewController = focusViewController;
    self.mediaView = mediaView;
    parentViewController = [self.delegate parentViewControllerForMediaFocusManager:self];
    [parentViewController addChildViewController:focusViewController];
    [parentViewController.view addSubview:focusViewController.view];
    // The focus view is generally
    focusViewController.view.frame = parentViewController.view.bounds;
    mediaView.hidden = YES;

    imageView = focusViewController.mainImageView;
    center = [imageView.superview convertPoint:mediaView.center fromView:mediaView.superview];
    imageView.center = center;
    imageView.transform = mediaView.transform;
    imageView.bounds = mediaView.bounds;
        
    self.isZooming = YES;
    
    finalImageFrame = [self.delegate mediaFocusManager:self finalFrameForView:mediaView];
    if(imageView.contentMode == UIViewContentModeScaleAspectFill)
    {
        CGSize size;
        
        size = [self sizeThatFitsInSize:finalImageFrame.size initialSize:imageView.image.size];
        finalImageFrame.size = size;
        finalImageFrame.origin.x = (focusViewController.view.bounds.size.width - size.width)/2;
        finalImageFrame.origin.y = (focusViewController.view.bounds.size.height - size.height)/2;
    }

    duration = (self.elasticAnimation?self.animationDuration*(1-kAnimateElasticDurationRatio):self.animationDuration);
    [UIView animateWithDuration:duration
                     animations:^{
                         CGRect frame;
                         CGRect initialFrame;
                         CGAffineTransform initialTransform;
                         
                         if (self.delegate && [self.delegate respondsToSelector:@selector(mediaFocusManagerWillAppear:)])
                         {
                             [self.delegate mediaFocusManagerWillAppear:self];
                         }
                         
                         frame = finalImageFrame;

                         // Trick to keep the right animation on the image frame.
                         // The image frame shoud animate from its current frame to a final frame.
                         // The final frame is computed by taking care of a possible rotation regarding the current device orientation, done by calling updateOrientationAnimated.
                         // As this method changes the image frame, it also replaces the current animation on the image view, which is not wanted.
                         // Thus to recreate the right animation, the image frame is set back to its inital frame then to its final frame.
                         // This very last frame operation recreates the right frame animation.
                         initialTransform = imageView.transform;
                         imageView.transform = CGAffineTransformIdentity;
                         initialFrame = imageView.frame;
                         imageView.frame = frame;
                         
                         if(_isPanoramic){
                             [focusViewController updateOrientationAnimated:NO];
                         }
                         // This is the final image frame. No transform.
                         untransformedFinalImageFrame = imageView.frame;
                         frame = (self.elasticAnimation?[self rectInsetsForRect:untransformedFinalImageFrame ratio:-kAnimateElasticSizeRatio]:untransformedFinalImageFrame);
                         // It must now be animated from its initial frame and transform.
                         imageView.frame = initialFrame;
                         imageView.transform = initialTransform;
                         imageView.transform = CGAffineTransformIdentity;
                         imageView.frame = frame;                         
                         focusViewController.view.backgroundColor = self.backgroundColor;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:(self.elasticAnimation?self.animationDuration*kAnimateElasticDurationRatio/3:0)
                                          animations:^{
                                              CGRect frame;
                                              
                                              frame = untransformedFinalImageFrame;
                                              frame = (self.elasticAnimation?[self rectInsetsForRect:frame ratio:kAnimateElasticSizeRatio*kAnimateElasticSecondMoveSizeRatio]:frame);
                                              imageView.frame = frame;
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:(self.elasticAnimation?self.animationDuration*kAnimateElasticDurationRatio/3:0)
                                                               animations:^{
                                                                   CGRect frame;
                                                                   
                                                                   frame = untransformedFinalImageFrame;
                                                                   frame = (self.elasticAnimation?[self rectInsetsForRect:frame ratio:-kAnimateElasticSizeRatio*kAnimateElasticThirdMoveSizeRatio]:frame);
                                                                   imageView.frame = frame;
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:(self.elasticAnimation?self.animationDuration*kAnimateElasticDurationRatio/3:0)
                                                                                    animations:^{
                                                                                        imageView.frame = untransformedFinalImageFrame;
                                                                                    }
                                                                                    completion:^(BOOL finished) {
                                                                                        [self installZoomView];
                                                                                        [self.focusViewController showAccessoryView:YES];
                                                                                        self.isZooming = NO;
                                                                                        
                                                                                        if (self.delegate && [self.delegate respondsToSelector:@selector(mediaFocusManagerDidAppear:)])
                                                                                        {
                                                                                            [self.delegate mediaFocusManagerDidAppear:self];
                                                                                        }
                                                                                    }];
                                                               }];
                                          }];
                     }];
}

- (void)handleDefocusGesture:(UIGestureRecognizer *)gesture
{
    NSTimeInterval duration;

    if(self.isZooming && self.gestureDisabledDuringZooming)
        return;
    
    UIView *contentView;
    CGRect __block bounds;
    
    [self uninstallZoomView];
    
    contentView = self.focusViewController.mainImageView;
    duration = (self.elasticAnimation?self.animationDuration*(1-kAnimateElasticDurationRatio):self.animationDuration);
    [UIView animateWithDuration:duration
                     animations:^{
                         if (self.delegate && [self.delegate respondsToSelector:@selector(mediaFocusManagerWillDisappear:)])
                         {
                             [self.delegate mediaFocusManagerWillDisappear:self];
                         }
                         
                         self.focusViewController.contentView.transform = CGAffineTransformIdentity;
                         contentView.center = [contentView.superview convertPoint:self.mediaView.center fromView:self.mediaView.superview];
                         contentView.transform = self.mediaView.transform;
                         bounds = self.mediaView.bounds;
                         contentView.bounds = (self.elasticAnimation?[self rectInsetsForRect:bounds ratio:kAnimateElasticSizeRatio]:bounds);
                         self.focusViewController.view.backgroundColor = [UIColor clearColor];
                         self.focusViewController.accessoryView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:(self.elasticAnimation?self.animationDuration*kAnimateElasticDurationRatio/3:0)
                                          animations:^{
                                              CGRect frame;
                                              
                                              frame = bounds;
                                              frame = (self.elasticAnimation?[self rectInsetsForRect:frame ratio:-kAnimateElasticSizeRatio*kAnimateElasticSecondMoveSizeRatio]:frame);
                                              contentView.bounds = frame;
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:(self.elasticAnimation?self.animationDuration*kAnimateElasticDurationRatio/3:0)
                                                               animations:^{
                                                                   CGRect frame;
                                                                   
                                                                   frame = bounds;
                                                                   frame = (self.elasticAnimation?[self rectInsetsForRect:frame ratio:kAnimateElasticSizeRatio*kAnimateElasticThirdMoveSizeRatio]:frame);
                                                                   contentView.bounds = frame;
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:(self.elasticAnimation?self.animationDuration*kAnimateElasticDurationRatio/3:0)
                                                                                    animations:^{
                                                                                        contentView.bounds = bounds;
                                                                                    }
                                                                                    completion:^(BOOL finished) {
                                                                                        self.mediaView.hidden = NO;
                                                                                        [self.focusViewController.view removeFromSuperview];
                                                                                        [self.focusViewController removeFromParentViewController];
                                                                                        self.focusViewController = nil;
                                                                                        
                                                                                        if (self.delegate && [self.delegate respondsToSelector:@selector(mediaFocusManagerDidDisappear:)])
                                                                                        {
                                                                                            [self.delegate mediaFocusManagerDidDisappear:self];
                                                                                        }
                                                                                    }];
                                                               }];
                                          }];
                     }];
}
@end

//
//  backgroundAnimate.m
//  bko
//
//  Created by Tito Español Gamón on 31/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "backgroundAnimate.h"

@implementation backgroundAnimate

CALayer *background;
CABasicAnimation *animation;

+ (backgroundAnimate *)sharedInstance {
    static dispatch_once_t onceToken;
    static backgroundAnimate *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[backgroundAnimate alloc] init];
    });
    return instance;
}

-(void)animateBackground:(UIImageView *)backgroundImageView {
    UIImage *backgroundImage = [UIImage imageNamed:@"1_loopblack.png"];
    UIColor *backgroundPattern = [UIColor colorWithPatternImage:backgroundImage];
    background = [CALayer layer];
    background.backgroundColor = backgroundPattern.CGColor;
    background.transform = CATransform3DMakeScale(1, -1, 1);
    background.anchorPoint = CGPointMake(0, 1);
    CGSize viewSize = backgroundImageView.bounds.size;
    background.frame = CGRectMake(0, 0, viewSize.width,  backgroundImage.size.height +   [[UIScreen mainScreen] bounds].size.height);
    [backgroundImageView.layer addSublayer:background];
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointMake(0, -backgroundImage.size.height);
    animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCGPoint:endPoint];
    animation.toValue = [NSValue valueWithCGPoint:startPoint];
    animation.repeatCount = HUGE_VALF;
    animation.duration = 20.0;
    [background addAnimation:animation forKey:@"position"];
}

- (void)applyCloudLayerAnimation {
    [background addAnimation:animation forKey:@"position"];
}

@end

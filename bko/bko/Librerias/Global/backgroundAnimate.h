//
//  backgroundAnimate.h
//  bko
//
//  Created by Tito Español Gamón on 31/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface backgroundAnimate : NSObject

+ (backgroundAnimate *)sharedInstance;
- (void)animateBackground:(UIImageView *)backgroundImageView;
- (void)applyCloudLayerAnimation;

@end

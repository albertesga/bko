//
//  mensajesIndexViewController.h
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALRadialMenu.h"
#import "ALRadialButton.h"

@interface mensajesIndexViewController : UIViewController <UITextViewDelegate,UIScrollViewDelegate,ALRadialMenuDelegate>
@property (strong, nonatomic) ALRadialMenu *radialMenu;
@end

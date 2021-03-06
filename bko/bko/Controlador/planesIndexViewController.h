//
//  planesIndexViewController.h
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALRadialMenu.h"
#import "ALRadialButton.h"
#import "SWRevealViewController.h"

@interface planesIndexViewController : UIViewController<SWRevealViewControllerDelegate,ALRadialMenuDelegate,UITextFieldDelegate>
@property (strong, nonatomic) ALRadialMenu *radialMenu;
@end

//
//  fichaViewController.h
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALRadialMenu.h"
#import "ALRadialButton.h"
#import "SWRevealViewController.h"
#import "ASMediaFocusManager.h"

@interface fichaViewController : UIViewController <ASMediasFocusDelegate,SWRevealViewControllerDelegate,ALRadialMenuDelegate,UIWebViewDelegate,UITextFieldDelegate>
@property (assign) int id_card;
@property (assign) int kind;
@property (strong, nonatomic) ALRadialMenu *radialMenu;
@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) ASMediaFocusManager *mediaFocusManager;
@property (nonatomic, assign) BOOL statusBarHidden;
@end

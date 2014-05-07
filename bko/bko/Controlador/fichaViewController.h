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

@interface fichaViewController : UIViewController <ALRadialMenuDelegate>
@property (assign) int id_card;
@property (assign) int kind;
@property (strong, nonatomic) ALRadialMenu *radialMenu;
@end

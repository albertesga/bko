//
//  pasesGratisIndexViewController.h
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALRadialButton.h"
#import "ALRadialMenu.h"

@interface pasesGratisIndexViewController : UIViewController<ALRadialMenuDelegate>
@property (strong, nonatomic) ALRadialMenu *radialMenu;
@end

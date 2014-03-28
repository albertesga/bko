//
//  actualidadIndexViewController.h
//  bko
//
//  Created by Tito Español Gamón on 21/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALRadialMenu.h"

@interface actualidadIndexViewController : UIViewController <ALRadialMenuDelegate>

@property (strong, nonatomic) ALRadialMenu *radialMenu;
- (IBAction)menuButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *MenuView;
@property (weak, nonatomic) IBOutlet UIView *MainView;

@end

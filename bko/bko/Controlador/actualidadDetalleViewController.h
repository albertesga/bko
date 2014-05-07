//
//  actualidadDetalleViewController.h
//  bko
//
//  Created by Tito Español Gamón on 21/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALRadialMenu.h"
#import "ALRadialButton.h"

@interface actualidadDetalleViewController : UIViewController<ALRadialMenuDelegate>

@property (strong, nonatomic) ALRadialMenu *radialMenu;
@property (assign) NSInteger id_articulo;

@end

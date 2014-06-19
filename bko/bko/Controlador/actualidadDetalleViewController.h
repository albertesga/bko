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
#import <MessageUI/MessageUI.h>
#import "ASMediaFocusManager.h"

@interface actualidadDetalleViewController : UIViewController<ASMediasFocusDelegate,ALRadialMenuDelegate,UIWebViewDelegate,MFMailComposeViewControllerDelegate,UITextFieldDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) ALRadialMenu *radialMenu;
@property (assign) NSInteger id_articulo;
@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) ASMediaFocusManager *mediaFocusManager;
@property (nonatomic, assign) BOOL statusBarHidden;


- (void)ordenar_vistas;

@end

//
//  agendaDetalleViewController.h
//  bko
//
//  Created by Tito Español Gamón on 25/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ALRadialButton.h"
#import "ALRadialMenu.h"
#import "SWRevealViewController.h"
#import "ASMediaFocusManager.h"

@interface agendaDetalleViewController : UIViewController <ASMediasFocusDelegate,SWRevealViewControllerDelegate,UIScrollViewDelegate,CLLocationManagerDelegate,ALRadialMenuDelegate,UIWebViewDelegate> {
    CLLocationManager *locationManager;
}
@property (assign) NSInteger id_party;
@property (strong, nonatomic) ALRadialMenu *radialMenu;
@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) ASMediaFocusManager *mediaFocusManager;
@property (nonatomic, assign) BOOL statusBarHidden;
@end

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

@interface agendaDetalleViewController : UIViewController <UIScrollViewDelegate,CLLocationManagerDelegate,ALRadialMenuDelegate> {
    CLLocationManager *locationManager;
}
@property (assign) NSInteger id_party;
@property (strong, nonatomic) ALRadialMenu *radialMenu;
@end

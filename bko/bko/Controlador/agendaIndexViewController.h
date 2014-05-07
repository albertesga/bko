//
//  agendaIndexViewController.h
//  bko
//
//  Created by Tito Español Gamón on 25/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ALRadialMenu.h"
#import "ALRadialButton.h"

@interface agendaIndexViewController : UIViewController <UIScrollViewDelegate,CLLocationManagerDelegate,ALRadialMenuDelegate> {
    CLLocationManager *locationManager;
}
    @property (strong, nonatomic) ALRadialMenu *radialMenu;

@end

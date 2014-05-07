//
//  registerNoFbPaso2ViewController.h
//  bko
//
//  Created by Tito Español Gamón on 10/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface registerNoFbPaso2ViewController : UIViewController<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}
@property (assign) NSInteger numero_likes;
@end

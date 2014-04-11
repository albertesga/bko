//
//  registerNoFbPaso2ViewController.m
//  bko
//
//  Created by Tito Español Gamón on 10/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "registerNoFbPaso2ViewController.h"
#import "testGustosViewController.h"
#import "actualidadIndexViewController.h"

@interface registerNoFbPaso2ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *text_image;
@property (weak, nonatomic) IBOutlet UIButton *siguiente;
@property (weak, nonatomic) IBOutlet UIImageView *text_image_ultimo_paso;
@property (weak, nonatomic) IBOutlet UIButton *iniciar_test;
@property (weak, nonatomic) IBOutlet UIButton *ahora_no;

@end

@implementation registerNoFbPaso2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
}
- (IBAction)siguiente:(id)sender {
    _siguiente.hidden = TRUE;
    _text_image.hidden = TRUE;
    _text_image_ultimo_paso.hidden = FALSE;
    _iniciar_test.hidden = FALSE;
    _ahora_no.hidden = FALSE;
}
- (IBAction)iniciar_test:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
    testGustosViewController *test =
    [storyboard instantiateViewControllerWithIdentifier:@"testGustosViewController"];
    [self presentViewController:test animated:NO completion:nil];
    
}
- (IBAction)iniciar_actualidad:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
    actualidadIndexViewController *actualidad =
    [storyboard instantiateViewControllerWithIdentifier:@"actualidadIndexViewController"];
    [self presentViewController:actualidad animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    int degrees = newLocation.coordinate.latitude;
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal * 3600 - minutes * 60;
    NSString *lat = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                     degrees, minutes, seconds];
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal * 60;
    seconds = decimal * 3600 - minutes * 60;
    NSString *longt = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                       degrees, minutes, seconds];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

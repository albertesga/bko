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
#import "SWRevealViewController.h"
#import "backgroundAnimate.h"
#import "sesion.h"
#import "register_dao.h"
#import "utils.h"
#import "sinConexionViewController.h"

@interface registerNoFbPaso2ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *text_image;
@property (weak, nonatomic) IBOutlet UIButton *siguiente;
@property (weak, nonatomic) IBOutlet UIImageView *text_image_ultimo_paso;
@property (weak, nonatomic) IBOutlet UIButton *iniciar_test;
@property (weak, nonatomic) IBOutlet UIButton *ahora_no;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation registerNoFbPaso2ViewController

@synthesize numero_likes;

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
    [self conectado];
    // Do any additional setup after loading the view.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    
}
- (IBAction)siguiente:(id)sender {
    [locationManager startUpdatingLocation];
}
- (IBAction)iniciar_test:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
    testGustosViewController *test =
    [storyboard instantiateViewControllerWithIdentifier:@"testGustosViewController"];
    [self presentViewController:test animated:NO completion:nil];

}
- (IBAction)iniciar_actualidad:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
    SWRevealViewController *actualidad =
    [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
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
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * latNumber = [[NSNumber alloc] initWithFloat:newLocation.coordinate.latitude];
    NSNumber * longNumber = [[NSNumber alloc] initWithFloat:newLocation.coordinate.longitude];
    
    sesion *s = [sesion sharedInstance];
    [[register_dao sharedInstance] setCoordinates:s.codigo_conexion latitude:latNumber longitude:longNumber y:^(NSArray *party, NSError *error){
        if (!error) {
            s.latitude = latNumber;
            s.longitude = longNumber;
            
            int numero_likes_minimos_para_evitar_test = 5;
            if(numero_likes<numero_likes_minimos_para_evitar_test){
                _siguiente.hidden = TRUE;
                _text_image.hidden = TRUE;
                _text_image_ultimo_paso.hidden = FALSE;
                _iniciar_test.hidden = FALSE;
                _ahora_no.hidden = FALSE;
            }
            else{
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
                SWRevealViewController *actualidad =
                [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
                [self presentViewController:actualidad animated:NO completion:nil];
            }
        } else {
            // Error hacer el like
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    _siguiente.hidden = TRUE;
    _text_image.hidden = TRUE;
    _text_image_ultimo_paso.hidden = FALSE;
    _iniciar_test.hidden = FALSE;
    _ahora_no.hidden = FALSE;
}

- (void)viewDidAppear:(BOOL)animated {
    
    //Llamamos al Singleton backgroundAnimate y ejecutamos la funcion que anima el background
    backgroundAnimate *background = [backgroundAnimate sharedInstance];
    [background animateBackground:self.backgroundImageView];
    
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)note {
    backgroundAnimate *background = [backgroundAnimate sharedInstance];
    [background animateBackground:self.backgroundImageView];
    [background applyCloudLayerAnimation];
}

-(void)conectado{
    if(![utils connected]){
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
        sinConexionViewController *sinConexion =
        [storyboard instantiateViewControllerWithIdentifier:@"sinConexionViewController"];
        [self presentViewController:sinConexion animated:NO completion:nil];
    }
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

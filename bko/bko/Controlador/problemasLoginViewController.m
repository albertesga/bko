//
//  problemasLoginViewController.m
//  bko
//
//  Created by Tito Español Gamón on 21/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "problemasLoginViewController.h"
#import "backgroundAnimate.h"
#import "utils.h"
#import "sinConexionViewController.h"
#import "register_dao.h"

@interface problemasLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *problemas_label;
@property (weak, nonatomic) IBOutlet UILabel *acceder_label;
@property (weak, nonatomic) IBOutlet UILabel *introduce_campos_label;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *nombre;
@property (weak, nonatomic) IBOutlet UITextField *email;

@end

@implementation problemasLoginViewController

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

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
    _problemas_label.font = FONT_BEBAS(18.0f);
    _acceder_label.font = FONT_BEBAS(18.0f);
    _introduce_campos_label.font = FONT_BEBAS(18.0f);
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    paddingView.backgroundColor = [UIColor clearColor];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    paddingView2.backgroundColor = [UIColor clearColor];
    UIColor *color = [UIColor blackColor];
    self.nombre.leftView = paddingView;
    self.nombre.leftViewMode = UITextFieldViewModeAlways;
    self.nombre.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Nombre y Apellidos" attributes:@{NSForegroundColorAttributeName: color}];
    self.email.leftView = paddingView2;
    self.email.leftViewMode = UITextFieldViewModeAlways;
    self.email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Dirección e-mail" attributes:@{NSForegroundColorAttributeName: color}];
    
    self.email.delegate = self;
    self.nombre.delegate = self;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)recuperarCodigo:(id)sender {
    [[register_dao sharedInstance] recoverPassword:_email.text name_surname:_nombre.text y:^(NSArray *connection, NSError *error) {
        if (!error) {
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:@"Se ha enviado un email a tu correo "
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        } else {
            // Error processing
            [utils controlarErrores:error];
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.email || theTextField == self.nombre) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //hides keyboard when another part of layout was touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


- (IBAction)textFieldDidBeginEditing:(id)sender {
    [self animateTextField: sender up: YES];
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender
{
    [self animateTextField: sender up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
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

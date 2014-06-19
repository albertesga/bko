//
//  loginViewController.m
//  bko
//
//  Created by Tito Español Gamón on 20/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "loginViewController.h"
#import "backgroundAnimate.h"
#import "register_dao.h"
#import <CommonCrypto/CommonDigest.h>
#import "SWRevealViewController.h"
#import "registerNoFbPaso2ViewController.h"
#import "sesion.h"
#import "utils.h"
#import "sinConexionViewController.h"
#import "message_dao.h"
#import "problemasLoginViewController.h"

@interface loginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *si_ya_tienes_label;
@property (weak, nonatomic) IBOutlet UILabel *por_favor_label;
@property (weak, nonatomic) IBOutlet UILabel *completa_los_campos_label;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation loginViewController

int contador = 0;
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
    contador = 0;
    [super viewDidLoad];
    [self conectado];
    self.email.delegate = self;
    self.password.delegate = self;
    self.password.secureTextEntry = YES;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    paddingView.backgroundColor = [UIColor clearColor];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    paddingView2.backgroundColor = [UIColor clearColor];
    UIColor *color = [UIColor blackColor];
    self.password.leftView = paddingView;
    self.password.leftViewMode = UITextFieldViewModeAlways;
    self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Contraseña" attributes:@{NSForegroundColorAttributeName: color}];
    self.email.leftView = paddingView2;
    self.email.leftViewMode = UITextFieldViewModeAlways;
    self.email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Dirección e-mail" attributes:@{NSForegroundColorAttributeName: color}];
    
    _si_ya_tienes_label.font = FONT_BEBAS(18.0f);
    _por_favor_label.font = FONT_BEBAS(18.0f);
    _completa_los_campos_label.font = FONT_BEBAS(18.0f);
    // Do any additional setup after loading the view.
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.email || theTextField == self.password) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    contador++;
    if(contador>2){
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
        problemasLoginViewController *problemas =
        [storyboard instantiateViewControllerWithIdentifier:@"problemasLoginViewController"];
        [self presentViewController:problemas animated:NO completion:nil];
    }
    NSString* password_md5 = [self md5:_password.text];
    [[register_dao sharedInstance] login:_email.text password:password_md5 token:[utils retrieveToken] y:^(NSArray *connection, NSError *error) {
        if (!error) {
                
                sesion *s = [sesion sharedInstance];
                NSDictionary* con = [connection objectAtIndex:0];
                s.codigo_conexion = [[con objectForKey:@"connection"] objectForKey:@"code"];
                [[message_dao sharedInstance] getUnreadMessagesCount:s.codigo_conexion y:^(NSArray *countMessages, NSError *error) {
                if (!error) {
                    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                    
                    NSDictionary* c = [countMessages objectAtIndex:0];
                    s.messages_unread = [c objectForKey:@"count"];
                } else {
                    // Error processing
                    NSLog(@"Error en la llamada del Recoger Mensajes: %@", error);
                    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                       message:[error localizedDescription]
                                                                      delegate:self
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                    [theAlert show];
                }
            }];
                [utils allowUserToUseApp:_email.text password:password_md5];
                if([[con objectForKey:@"test"] intValue]==1){
                    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
                    registerNoFbPaso2ViewController *actualidad =
                    [storyboard instantiateViewControllerWithIdentifier:@"registerNoFbPaso2ViewController"];
                    actualidad.numero_likes = 0;
                    [self presentViewController:actualidad animated:NO completion:nil];
                }
                else{
                    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
                    SWRevealViewController *actualidad =
                    [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
                    [self presentViewController:actualidad animated:NO completion:nil];
            }
        } else {
            // Error processing
            [utils controlarErrores:error];
        }
    }];

}

- (NSString *)md5:(NSString*)pass
{
    NSString* salt = @"DYhG93b0qyJfIxfs2gufoUubWwvneR2G0FgaC9mi";
    NSString *value = [salt stringByAppendingString:pass];
    const char *cStr = [value UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (void)viewDidAppear:(BOOL)animated {
    contador = 0;
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

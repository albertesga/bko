//
//  registerNoFbViewController.m
//  bko
//
//  Created by Tito Español Gamón on 21/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "registerNoFbViewController.h"
#import "backgroundAnimate.h"
#import "register_dao.h"
#import "mailEnviadoViewController.h"
#import "utils.h"
#import "sinConexionViewController.h"

@interface registerNoFbViewController ()
@property (weak, nonatomic) IBOutlet UILabel *por_favor;
@property (weak, nonatomic) IBOutlet UILabel *si_no_facebook;
@property (weak, nonatomic) IBOutlet UILabel *completa_los_campos;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *nombre;
@property (weak, nonatomic) IBOutlet UITextField *apellidos;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *fecha_nacimiento;

@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation registerNoFbViewController

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
    _si_no_facebook.font = FONT_BEBAS(18.0f);
    _por_favor.font = FONT_BEBAS(18.0f);
    _completa_los_campos.font = FONT_BEBAS(18.0f);
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    paddingView.backgroundColor = [UIColor clearColor];
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    paddingView2.backgroundColor = [UIColor clearColor];
    UIView *paddingView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    paddingView3.backgroundColor = [UIColor clearColor];
    UIView *paddingView4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    UIColor *color = [UIColor blackColor];
    paddingView4.backgroundColor = [UIColor clearColor];
    self.nombre.leftView = paddingView;
    self.nombre.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Nombre..." attributes:@{NSForegroundColorAttributeName: color}];
    self.nombre.leftViewMode = UITextFieldViewModeAlways;
    self.email.leftView = paddingView2;
    self.email.leftViewMode = UITextFieldViewModeAlways;
    self.email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Dirección e-mail..." attributes:@{NSForegroundColorAttributeName: color}];
    self.apellidos.leftView = paddingView3;
    self.apellidos.leftViewMode = UITextFieldViewModeAlways;
    self.apellidos.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Apellidos..." attributes:@{NSForegroundColorAttributeName: color}];
    self.fecha_nacimiento.leftView = paddingView4;
    self.fecha_nacimiento.leftViewMode = UITextFieldViewModeAlways;
    self.fecha_nacimiento.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Tu fecha de nacimiento..." attributes:@{NSForegroundColorAttributeName: color}];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.nombre || theTextField == self.apellidos  || theTextField == self.email || theTextField == self.fecha_nacimiento) {
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

- (IBAction)dateTextFieldEndEditing:(id)sender {
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

// ********* VALIDATIONS ***********
- (BOOL)validateInputEmail:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:_email.text];
}

- (IBAction)validateEmail:(id)sender {
    if(![self validateInputEmail:[_email text]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Escribe un mail correcto." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}


- (IBAction)siguiente:(id)sender {
    if(![self validateInputEmail:[_email text]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Escribe un mail correcto." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else{
        [[register_dao sharedInstance] addUser:_email.text name:_nombre.text surname:_apellidos.text birthdate:_fecha_nacimiento.text y:^(NSArray *password, NSError *error) {
            if (!error) {
            //Hacemos login para tener el código de conexión
                    NSLog(@"PASSWORD: %@",[password objectAtIndex:0]);

                    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
                    mailEnviadoViewController *actualidad =
                    [storyboard instantiateViewControllerWithIdentifier:@"mailEnviadoViewController"];
                    [self presentViewController:actualidad animated:NO completion:nil];
            
            } else {
                // Error processing
                [utils controlarErrores:error];
            }
    }];
    }
}

- (IBAction)mostrarDatePicker:(id)sender {
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)note {
    backgroundAnimate *background = [backgroundAnimate sharedInstance];
    [background animateBackground:self.backgroundImageView];
    [background applyCloudLayerAnimation];
}

- (IBAction)callDatePicker:(id)sender {
    [_email resignFirstResponder];
    [_apellidos resignFirstResponder];
    [_nombre resignFirstResponder];
    
    [_fecha_nacimiento endEditing:YES];
    if ([self.view viewWithTag:9]) {
        return;
    }
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 320, 216);
    
    UIView *whiteView = [[UIView alloc] initWithFrame:self.view.bounds];
    whiteView.alpha = 0;
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.tag = 9;
    whiteView.frame = CGRectMake(0, self.view.bounds.size.height-216, 320, 216);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)] ;
    [whiteView addGestureRecognizer:tapGesture];
    [self.view addSubview:whiteView];
    
    NSDateComponents* dc = [[NSDateComponents alloc] init];
    [dc setYear:2000];
    [dc setMonth:12];
    [dc setDay:31];
    NSCalendar* c = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate* date = [c dateFromComponents:dc];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    datePicker.tag = 10;
    datePicker.datePickerMode = UIDatePickerModeDate;
    //datePicker.maximumDate = date;
    datePicker.date = date;
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)] ;
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 6, 60, 30)];
    [customButton setTitle:@"Ok" forState:UIControlStateNormal];
    [customButton addTarget:self action:@selector(dismissDatePicker:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    datePicker.frame = datePickerTargetFrame;
    whiteView.alpha = 1;
    [UIView commitAnimations];
}

- (void)changeDate:(UIDatePicker *)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:sender.date];
    _fecha_nacimiento.text= stringFromDate;
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
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

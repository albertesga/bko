//
//  mensajesIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "mensajesIndexViewController.h"
#import "SWRevealViewController.h"

@interface mensajesIndexViewController ()

@property (weak, nonatomic) IBOutlet UIView *modal_escribir;
@property (weak, nonatomic) IBOutlet UIView *modal_mensaje;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation mensajesIndexViewController

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
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 118;
    
    //Las UIViews de cada
    UIView *contenedorView=[[UIView alloc]initWithFrame:CGRectMake(15, 10, 290, 90)];
    [contenedorView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:contenedorView];
    
    UIButton *buttonMensaje = [[UIButton alloc] initWithFrame:CGRectMake(56, 55, 154, 154)];
    [buttonMensaje setBackgroundColor:[UIColor whiteColor]];
    [contenedorView addSubview:buttonMensaje];
    [buttonMensaje addTarget:self action:@selector(verMensaje) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *tituloMensaje = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 153, 21)];
    [contenedorView addSubview:tituloMensaje];
    tituloMensaje.text=@"BKO TEAM";
    tituloMensaje.textColor=[UIColor colorWithRed:0.0/255.0f green:155.0/255.0f blue:124.0/255.0f alpha:1];
    tituloMensaje.font = FONT_BEBAS(18.0f);
    tituloMensaje.textAlignment=NSTextAlignmentLeft;
    
    UILabel *fechaMensaje = [[UILabel alloc] initWithFrame:CGRectMake(171, 8, 99, 21)];
    [contenedorView addSubview:fechaMensaje];
    fechaMensaje.text=@"23 NOVIEMBRE";
    fechaMensaje.textColor=[UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1];
    fechaMensaje.font = FONT_BEBAS(18.0f);
    fechaMensaje.textAlignment=NSTextAlignmentRight;
    
    UITextView *mensaje = [[UITextView alloc] initWithFrame:CGRectMake(10, 26, 275, 60)];
    [contenedorView addSubview:mensaje];
    [mensaje setBackgroundColor:[UIColor whiteColor]];
    mensaje.text=@"A MUCHOS QUE LES GUSTA RICHIE HAWTIN Y GAISER TAMBIEN LES GUSTA TALE OF US A MUCHOS QUE LES GUSTA RICHIE HAWTIN Y GAISER TAMBIEN LES GUSTA TALE OF US";
    mensaje.textColor=[UIColor blackColor];
    mensaje.font = FONT_BEBAS(14.0f);
    mensaje.textAlignment=NSTextAlignmentLeft;
}

- (IBAction)escribir_mensaje:(id)sender {
    _modal_escribir.hidden = false;
}

- (IBAction)salir_escribir:(id)sender {
    _modal_escribir.hidden = true;
}
- (IBAction)ver_mensaje:(id)sender {
    _modal_mensaje.hidden = false;
}
- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

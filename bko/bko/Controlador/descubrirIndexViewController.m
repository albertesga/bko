//
//  descubrirIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "descubrirIndexViewController.h"
#import "SWRevealViewController.h"

@interface descubrirIndexViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation descubrirIndexViewController

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
    UIView *contenedorView=[[UIView alloc]initWithFrame:CGRectMake(22, 65, 275, 257)];
    [contenedorView setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    [_scrollView addSubview:contenedorView];
    
    UITextView *tituloDescubrir = [[UITextView alloc] initWithFrame:CGRectMake(7, 1, 265, 54)];
    [contenedorView addSubview:tituloDescubrir];
    [tituloDescubrir setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    tituloDescubrir.text=@"A MUCHOS QUE LES GUSTA RICHIE HAWTIN Y GAISER TAMBIEN LES GUSTA TALE OF US";
    tituloDescubrir.textColor=[UIColor blackColor];
    tituloDescubrir.font = FONT_BEBAS(18.0f);
    tituloDescubrir.textAlignment=NSTextAlignmentCenter;
    
    UIButton *buttonImagenDescubrir = [[UIButton alloc] initWithFrame:CGRectMake(56, 55, 154, 154)];
    [buttonImagenDescubrir setBackgroundImage:[UIImage imageNamed:@"IMATGE.png"]forState:UIControlStateNormal];
    [contenedorView addSubview:buttonImagenDescubrir];
    [buttonImagenDescubrir addTarget:self action:@selector(detallesGrupo) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imagen_fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(60, 180, 147, 26)];
    [imagen_fondo_box setImage:[UIImage imageNamed:@"FONDO_IMAGEN.png"]];
    [contenedorView addSubview:imagen_fondo_box];
    
    UILabel *tituloImagenDescubrir = [[UILabel alloc] initWithFrame:CGRectMake(60, 184, 150, 21)];
    [contenedorView addSubview:tituloImagenDescubrir];
    tituloImagenDescubrir.text=@"hola";
    tituloImagenDescubrir.textColor=[UIColor whiteColor];
    tituloImagenDescubrir.font = FONT_BEBAS(16.0f);
    tituloImagenDescubrir.textAlignment=NSTextAlignmentCenter;
    
    UIButton *buttonSiMeGusta = [[UIButton alloc] initWithFrame:CGRectMake(7, 226, 115, 21)];
    [buttonSiMeGusta setBackgroundImage:[UIImage imageNamed:@"8_button_SI_ME_GUSTA.png"]forState:UIControlStateNormal];
    [contenedorView addSubview:buttonSiMeGusta];
    [buttonSiMeGusta addTarget:self action:@selector(siMeGusta) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonNoMeGusta = [[UIButton alloc] initWithFrame:CGRectMake(149, 226, 115, 21)];
    [buttonNoMeGusta setBackgroundImage:[UIImage imageNamed:@"8_button_NO_ME_GUSTA.png"]forState:UIControlStateNormal];
    [contenedorView addSubview:buttonNoMeGusta];
    [buttonNoMeGusta addTarget:self action:@selector(noMeGusta) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *derecha = [[UIButton alloc] initWithFrame:CGRectMake(305, 188, 6, 11)];
    [derecha setBackgroundImage:[UIImage imageNamed:@"8_icon_DERECHA.png"]forState:UIControlStateNormal];
    [_scrollView addSubview:derecha];
    [derecha addTarget:self action:@selector(mas) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *izquierda = [[UIButton alloc] initWithFrame:CGRectMake(10, 188, 6, 11)];
    [izquierda setBackgroundImage:[UIImage imageNamed:@"8_icon_IZQUIERDA.png"]forState:UIControlStateNormal];
    [_scrollView addSubview:izquierda];
    [izquierda addTarget:self action:@selector(menos) forControlEvents:UIControlEventTouchUpInside];
}
- (IBAction)back:(id)sender {
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

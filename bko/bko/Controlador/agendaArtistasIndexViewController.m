//
//  agendaArtistasIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 25/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "agendaArtistasIndexViewController.h"
#import "SWRevealViewController.h"
#import "agendaDetalleViewController.h"

@interface agendaArtistasIndexViewController ()
@property (weak, nonatomic) IBOutlet UILabel *agenda_label;
@property (weak, nonatomic) IBOutlet UILabel *fecha_label;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation agendaArtistasIndexViewController

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
    _fecha_label.font = FONT_BEBAS(13.0f);
    
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 118;
    
    //Las UIViews de cada
    UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(5, 5, 105, 105)];
    [paintView setBackgroundColor:[UIColor clearColor]];
    [_scrollView addSubview:paintView];
    
    UIButton *buttonActualidad = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 105, 105)];
    [buttonActualidad setBackgroundImage:[UIImage imageNamed:@"IMATGE.png"]forState:UIControlStateNormal];
    [paintView addSubview:buttonActualidad];
    [buttonActualidad addTarget:self action:@selector(detallesAgenda) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imagen_fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(2, 82, 100, 20)];
    [imagen_fondo_box setImage:[UIImage imageNamed:@"FONDO_IMAGEN.png"]];
    [paintView addSubview:imagen_fondo_box];
    
    UILabel *tituloActualidad = [[UILabel alloc] initWithFrame:CGRectMake(5, 82, 100, 21)];
    [paintView addSubview:tituloActualidad];
    tituloActualidad.text=@"maarco carolas";
    tituloActualidad.textColor=[UIColor whiteColor];
    tituloActualidad.font = FONT_BEBAS(13.0f);
    tituloActualidad.textAlignment=NSTextAlignmentCenter;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)detallesAgenda
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    agendaDetalleViewController *agendaController =
    [storyboard instantiateViewControllerWithIdentifier:@"agendaDetalleViewController"];
    
    [self.navigationController pushViewController:agendaController animated:YES];
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

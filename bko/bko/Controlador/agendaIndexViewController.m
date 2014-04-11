//
//  agendaIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 25/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "agendaIndexViewController.h"
#import "SWRevealViewController.h"
#import "agendaDetalleViewController.h"

@interface agendaIndexViewController ()
@property (weak, nonatomic) IBOutlet UILabel *fecha_label;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation agendaIndexViewController

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
    
    //Las UIViews de agenda
    UIView *agendaView=[[UIView alloc]initWithFrame:CGRectMake(2, 0, 317, 114)];
    [agendaView setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    [_scrollView addSubview:agendaView];
    
    UIButton *buttonActualidad = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 317, 114)];
    [buttonActualidad setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    [buttonActualidad setBackgroundImage:[UIImage imageNamed:@"5_BACK_EVENTO.png"]forState:UIControlStateNormal];
    [agendaView addSubview:buttonActualidad];
    [buttonActualidad addTarget:self action:@selector(detallesAgenda) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imagen = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 100, 100)];
    [agendaView addSubview:imagen];
    
    UIView *cuandoView=[[UIView alloc]initWithFrame:CGRectMake(115, 7, 192, 20)];
    [cuandoView setBackgroundColor:[UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1]];
    [agendaView addSubview:cuandoView];
    
    UILabel *nombreAgenda = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 120, 21)];
    [cuandoView addSubview:nombreAgenda];
    nombreAgenda.text=@"hola";
    nombreAgenda.textColor=[UIColor whiteColor];
    nombreAgenda.font = FONT_BEBAS(16.0f);
    
    UIImageView *icono_reloj = [[UIImageView alloc] initWithFrame:CGRectMake(145, 5, 11, 11)];
    [icono_reloj setImage:[UIImage imageNamed:@"5_icon_TIEMPO.png"]];
    [cuandoView addSubview:icono_reloj];
    
    UILabel *cuandoAgenda = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 43, 21)];
    [cuandoView addSubview:cuandoAgenda];
    cuandoAgenda.text=@"00:00";
    cuandoAgenda.textColor=[UIColor whiteColor];
    cuandoAgenda.font = FONT_BEBAS(16.0f);
    
    UIImageView *icono_donde = [[UIImageView alloc] initWithFrame:CGRectMake(120, 89, 13, 18)];
    [icono_donde setImage:[UIImage imageNamed:@"5_ICONO_PUNTO.png"]];
    [agendaView addSubview:icono_donde];
    
    UITextView *descripcionAgenda = [[UITextView alloc] initWithFrame:CGRectMake(115, 28, 192, 57)];
    [descripcionAgenda setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    [agendaView addSubview:descripcionAgenda];
    descripcionAgenda.text=@"BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB";
    descripcionAgenda.textColor=[UIColor blackColor];
    descripcionAgenda.font = FONT_BEBAS(13.0f);
    
    UILabel *dondeAgenda = [[UILabel alloc] initWithFrame:CGRectMake(141, 87, 142, 21)];
    [agendaView addSubview:dondeAgenda];
    dondeAgenda.text=@"BLOC CLUB";
    dondeAgenda.textColor=[UIColor blackColor];
    dondeAgenda.font = FONT_BEBAS(18.0f);
    
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

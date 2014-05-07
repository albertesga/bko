//
//  pasesGratisIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "pasesGratisIndexViewController.h"
#import "SWRevealViewController.h"
#import "utils.h"
#import "sesion.h"
#import "actualidadIndexViewController.h"
#import "agendaIndexViewController.h"
#import "sorteosIndexViewController.h"

@interface pasesGratisIndexViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;

@end

@implementation pasesGratisIndexViewController

int numero_pases = 0;
#define limit_paginate ((int) 6)
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
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    UILabel *no_hay_sugerencias = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 21)];
    no_hay_sugerencias.font = FONT_BEBAS(16.0f);
    no_hay_sugerencias.text = @"NO HAY PASES GRATIS";
    no_hay_sugerencias.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:no_hay_sugerencias];
    
    //Las UIViews de agenda
    /*UIView *pasesView=[[UIView alloc]initWithFrame:CGRectMake(5, 20, 310, 314)];
    [pasesView setBackgroundColor: [UIColor whiteColor]];
    [_scrollView addSubview:pasesView];
    
    UIImageView *imagen = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 100, 100)];
    [pasesView addSubview:imagen];
    
    UIView *cuandoView=[[UIView alloc]initWithFrame:CGRectMake(5, 7, 300, 20)];
    [cuandoView setBackgroundColor:[UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1]];
    [pasesView addSubview:cuandoView];
    
    UILabel *nombreAgenda = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 220, 21)];
    [cuandoView addSubview:nombreAgenda];
    nombreAgenda.text=@"viernes - 22 - diciembre";
    nombreAgenda.textColor=[UIColor whiteColor];
    nombreAgenda.font = FONT_BEBAS(16.0f);
    
    UIImageView *icono_reloj = [[UIImageView alloc] initWithFrame:CGRectMake(245, 5, 11, 11)];
    [icono_reloj setImage:[UIImage imageNamed:@"5_icon_TIEMPO.png"]];
    [cuandoView addSubview:icono_reloj];
    
    UILabel *cuandoAgenda = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 43, 21)];
    [cuandoView addSubview:cuandoAgenda];
    cuandoAgenda.text=@"00:00";
    cuandoAgenda.textColor=[UIColor whiteColor];
    cuandoAgenda.font = FONT_BEBAS(16.0f);
    
    
    UITextView *descripcionAgenda = [[UITextView alloc] initWithFrame:CGRectMake(115, 28, 192, 57)];
    [descripcionAgenda setBackgroundColor:[UIColor whiteColor]];
    [pasesView addSubview:descripcionAgenda];
    descripcionAgenda.text=@"BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB";
    descripcionAgenda.textColor=[UIColor blackColor];
    descripcionAgenda.font = FONT_BEBAS(13.0f);
    
    UIButton *dondeAgenda = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 25)];
    [dondeAgenda setBackgroundImage:[UIImage imageNamed:@"9_button_CONDICIONES.png"]forState:UIControlStateNormal];
    [pasesView addSubview:dondeAgenda];*/
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)desplegar_menu_radial:(id)sender {
    
    [self.radialMenu buttonsWillAnimateFromButton:sender withFrame:self.menu_button.frame inView:self.view];
    [UIView transitionWithView:_degradado_menu
                      duration:0.8
                       options:
     UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    if(_degradado_menu.hidden){
        [self.view bringSubviewToFront:_degradado_menu];
        [self.view bringSubviewToFront:self.menu_button];
        for (id o in self.radialMenu.items){
            [self.view bringSubviewToFront:o];
        }
        
        _degradado_menu.hidden = false;
    }
    else{
        _degradado_menu.hidden = true;
    }
}

#pragma mark - radial menu delegate methods
- (NSInteger) numberOfItemsInRadialMenu:(ALRadialMenu *)radialMenu {
    return 3;
}


- (NSInteger) arcSizeForRadialMenu:(ALRadialMenu *)radialMenu {
    //Tamaño en grados de lo que ocupa el menu
    return 65;
}


- (NSInteger) arcRadiusForRadialMenu:(ALRadialMenu *)radialMenu {
    //Distancia entre el icono y el menu
    return 80;
}
- (NSInteger) arcStartForRadialMenu:(ALRadialMenu *)radialMenu {
    //Donde empieza el menu
    return 275;
}


- (UIImage *) radialMenu:(ALRadialMenu *)radialMenu imageForIndex:(NSInteger) index {
	if (radialMenu == self.radialMenu) {
		if (index == 1) {
			return [UIImage imageNamed:@"1_ACTUALIDAD"];
		} else if (index == 2) {
			return [UIImage imageNamed:@"1_AGENDA"];
		} else if (index == 3) {
			return [UIImage imageNamed:@"1_SORTEOS"];
		}
        
	}
	return nil;
}


- (void) radialMenu:(ALRadialMenu *)radialMenu didSelectItemAtIndex:(NSInteger)index {
    _degradado_menu.hidden = true;
	if (radialMenu == self.radialMenu) {
		[self.radialMenu itemsWillDisapearIntoButton:self.menu_button];
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];
		if (index == 1) {
            //Se hace click en el label de actualidad
			actualidadIndexViewController *actualidadController =
            [storyboard instantiateViewControllerWithIdentifier:@"actualidadIndexViewController"];
            
            [self.navigationController pushViewController:actualidadController animated:YES];
		} else if (index == 2) {
            //Se hace click en el label de agenda
            
            agendaIndexViewController *agendaController =
            [storyboard instantiateViewControllerWithIdentifier:@"agendaIndexViewController"];
            
            [self.navigationController pushViewController:agendaController animated:YES];
			
		} else if (index == 3) {
            //Se hace click en el label de sorteos
            
            sorteosIndexViewController *sorteosController =
            [storyboard instantiateViewControllerWithIdentifier:@"sorteosIndexViewController"];
            
            [self.navigationController pushViewController:sorteosController animated:YES];
		}
	}
}

- (void)itemsWillDisapearIntoButton:(UIButton *)button{
    _degradado_menu.hidden = true;
}

- (IBAction)menuButton:(id)sender {
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


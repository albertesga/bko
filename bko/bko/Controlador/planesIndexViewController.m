//
//  planesIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "planesIndexViewController.h"
#import "SWRevealViewController.h"
#import "CKCalendarView.h"
#import "agendaDetalleViewController.h"
#import "party_dao.h"
#import "sesion.h"
#import "actualidadIndexViewController.h"
#import "agendaIndexViewController.h"
#import "sorteosIndexViewController.h"

@interface planesIndexViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (strong, nonatomic) IBOutlet UIView *vista;

@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;

@end

@implementation planesIndexViewController

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    for (UIView* v in _vista.subviews){
        if(v.tag==2){
            [v removeFromSuperview];
        }
    }
    sesion *s = [sesion sharedInstance];
    [[party_dao sharedInstance] getPlans:s.codigo_conexion date:date y:^(NSArray *places, NSError *error) {
        if (!error) {
            NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
            [dfDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            for (NSDictionary *JSONnoteData in places) {
                
                NSDate* date2 = [dfDate dateFromString:[[JSONnoteData objectForKey:@"party"] objectForKey:@"start_date"]];
                
                if([calendar date:date isSameDayAsDate:date2]){
                    [self mostrar_evento:JSONnoteData];
                }
                
            }
            [calendar reloadData];
            
        } else {
            // Error processing
            NSLog(@"Error al recoger places: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
    }];
}

- (void)calendar:(CKCalendarView *)calendar didChangeToMonth:(NSDate *)date {
    sesion *s = [sesion sharedInstance];
    [[party_dao sharedInstance] getPlans:s.codigo_conexion date:date y:^(NSArray *places, NSError *error) {
        if (!error) {
            NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
            [dfDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            for (NSDictionary *JSONnoteData in places) {
                [calendar setDateWithEvent:[dfDate dateFromString:[[JSONnoteData objectForKey:@"party"] objectForKey:@"start_date"]]];
            }
            [calendar reloadData];
            
        } else {
            // Error processing
            NSLog(@"Error al recoger places: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *no_hay_eventos = [[UILabel alloc] initWithFrame:CGRectMake(20, 300, 280, 21)];
    no_hay_eventos.font = FONT_BEBAS(16.0f);
    no_hay_eventos.text = @"SELECCIONA UN DIA CON PLAN PARA VERLO EN DETALLE";
    no_hay_eventos.textAlignment = NSTextAlignmentCenter;
    no_hay_eventos.textColor = [UIColor colorWithRed:163.0/255.0f green:163.0/255.0f blue:163.0/255.0f alpha:1];
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    [self.vista addSubview:no_hay_eventos];
    
    CKCalendarView *calendar = [[CKCalendarView alloc] init];
    [_vista addSubview:calendar];
    calendar.delegate = self;
    
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 118;
    sesion *s = [sesion sharedInstance];
    [[party_dao sharedInstance] getPlans:s.codigo_conexion date:[NSDate date] y:^(NSArray *places, NSError *error) {
        if (!error) {
            NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
            [dfDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            for (NSDictionary *JSONnoteData in places) {
                [calendar setDateWithEvent:[dfDate dateFromString:[[JSONnoteData objectForKey:@"party"] objectForKey:@"start_date"]]];
            }
            [calendar reloadData];

        } else {
            // Error processing
            NSLog(@"Error al recoger places: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
    }];
}

- (void)mostrar_evento:(NSDictionary*)json {
    //Las UIViews de agenda
    UIView *agendaView=[[UIView alloc]initWithFrame:CGRectMake(2, 275 , 317, 114)];
    [agendaView setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    
    UIButton *buttonEvento = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 317, 114)];
    [buttonEvento setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    [buttonEvento setBackgroundImage:[UIImage imageNamed:@"5_BACK_EVENTO.png"]forState:UIControlStateNormal];
    [agendaView addSubview:buttonEvento];
    [buttonEvento addTarget:self action:@selector(detallesAgenda:) forControlEvents:UIControlEventTouchUpInside];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *id_artist =[f numberFromString:[[json objectForKey:@"party"] objectForKey:@"id"]];
    [buttonEvento setTag:[id_artist intValue]];
    
    UIImageView *imagen = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 100, 100)];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[json objectForKey:@"party"] objectForKey:@"list_img"]]];
    [imagen setImage:[UIImage imageWithData:imageData]];
    [agendaView addSubview:imagen];
    UIView *cuandoView=[[UIView alloc]initWithFrame:CGRectMake(115, 7, 192, 20)];
    [cuandoView setBackgroundColor:[UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1]];
    [agendaView addSubview:cuandoView];
    UILabel *nombreAgenda = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 120, 21)];
    [cuandoView addSubview:nombreAgenda];
    nombreAgenda.text=[[json objectForKey:@"party"] objectForKey:@"list_name"];
    nombreAgenda.textColor=[UIColor whiteColor];
    nombreAgenda.font = FONT_BEBAS(16.0f);
    
    UIImageView *icono_reloj = [[UIImageView alloc] initWithFrame:CGRectMake(145, 5, 11, 11)];
    [icono_reloj setImage:[UIImage imageNamed:@"5_icon_TIEMPO.png"]];
    [cuandoView addSubview:icono_reloj];
    
    UILabel *cuandoAgenda = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 43, 21)];
    [cuandoView addSubview:cuandoAgenda];
    
    NSString* date = [[[json objectForKey:@"party"] objectForKey:@"start_date"] substringFromIndex:11];
    cuandoAgenda.text= [date substringToIndex:5];
    cuandoAgenda.textColor=[UIColor whiteColor];
    cuandoAgenda.font = FONT_BEBAS(16.0f);
    
    UIImageView *icono_donde = [[UIImageView alloc] initWithFrame:CGRectMake(120, 89, 13, 18)];
    [icono_donde setImage:[UIImage imageNamed:@"5_ICONO_PUNTO.png"]];
    [agendaView addSubview:icono_donde];
    
    UITextView *descripcionAgenda = [[UITextView alloc] initWithFrame:CGRectMake(115, 28, 192, 57)];
    [descripcionAgenda setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    [agendaView addSubview:descripcionAgenda];
    descripcionAgenda.text=[[json objectForKey:@"party"] objectForKey:@"list_description"];
    descripcionAgenda.textColor=[UIColor blackColor];
    descripcionAgenda.font = FONT_BEBAS(13.0f);
    descripcionAgenda.editable = NO;
    descripcionAgenda.scrollEnabled = NO;
    
    UILabel *dondeAgenda = [[UILabel alloc] initWithFrame:CGRectMake(141, 87, 142, 21)];
    [agendaView addSubview:dondeAgenda];
    dondeAgenda.text=[json objectForKey:@"name"];
    dondeAgenda.textColor=[UIColor blackColor];
    dondeAgenda.font = FONT_BEBAS(18.0f);
    agendaView.tag = 2;
    [_vista addSubview:agendaView];
    agendaView.alpha = 0.0;
    agendaView.transform =CGAffineTransformMakeScale(0,0);
    [UIView animateWithDuration:0.5 animations:^{
        agendaView.alpha = 1.0;
        agendaView.transform =CGAffineTransformMakeScale(1.0,1.0);
    }];
}


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)detallesAgenda:(UIButton*)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    agendaDetalleViewController *agendaController =
    [storyboard instantiateViewControllerWithIdentifier:@"agendaDetalleViewController"];
    agendaController.id_party = sender.tag;
    [self.navigationController pushViewController:agendaController animated:YES];
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

//
//  sorteosIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 25/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "sorteosIndexViewController.h"
#import "SWRevealViewController.h"
#import "raffle_dao.h"
#import "utils.h"
#import "sesion.h"
#import "actualidadIndexViewController.h"
#import "agendaIndexViewController.h"
#import "sorteosIndexViewController.h"

@interface sorteosIndexViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *altura_scroll;

@property (weak, nonatomic) IBOutlet UIView *view_scroll;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@end

@implementation sorteosIndexViewController

int numero_sorteos = 0;
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
    sesion *s = [sesion sharedInstance];
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;

    NSNumber *desde = [NSNumber numberWithInteger:numero_sorteos];
    NSNumber *hasta = [NSNumber numberWithInteger:limit_paginate];
    [[raffle_dao sharedInstance] getRaffles:s.codigo_conexion limit:hasta page:desde y:^(NSArray *sorteos, NSError *error) {
        if (!error) {
            for (NSDictionary *JSONnoteData in sorteos) {
                NSLog(@"SORTEO %@",JSONnoteData);
                [self showRaffle:JSONnoteData];
            }
            [self autoHeight];
        } else {
            // Error processing
            NSLog(@"Error al recoger parties places: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    numero_sorteos = 0;
}

- (void) showRaffle:(NSDictionary*)json{
    //Las UIViews de cada
    UIView *contenedorView=[[UIView alloc]initWithFrame:CGRectMake(12, numero_sorteos*320 + 10, 297, 290)];
    numero_sorteos++;
    [contenedorView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:contenedorView];
    
    UILabel *tituloSorteos = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 277, 21)];
    [contenedorView addSubview:tituloSorteos];
    tituloSorteos.text=[json objectForKey:@"title"];
    tituloSorteos.textColor=[UIColor blackColor];
    tituloSorteos.font = FONT_BEBAS(22.0f);
    tituloSorteos.textAlignment=NSTextAlignmentCenter;
    
    UILabel *subtituloSorteos = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 277, 21)];
    [contenedorView addSubview:subtituloSorteos];
    subtituloSorteos.text=[[[[[json valueForKey:@"for"] stringByAppendingString:@" @ "] stringByAppendingString:[json valueForKey:@"author"]]stringByAppendingString:@" - "] stringByAppendingString:[utils fechaConFormatoMensaje:[[json valueForKey:@"party"] valueForKey:@"date"]]];
    subtituloSorteos.textColor=[UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1];
    subtituloSorteos.font = FONT_BEBAS(22.0f);
    subtituloSorteos.textAlignment=NSTextAlignmentCenter;
    
    UIImageView *imagen_sorteo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 60, 277, 120)];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[json valueForKey:@"party"] valueForKey:@"img"]]];
    [imagen_sorteo setImage:[UIImage imageWithData:imageData]];
    [contenedorView addSubview:imagen_sorteo];
    
    if([[json objectForKey:@"winners"] count]==0){
        UILabel *listaGanadores = [[UILabel alloc] initWithFrame:CGRectMake(24, 188, 248, 21)];
        [contenedorView addSubview:listaGanadores];
        listaGanadores.text=@"la lista de ganadores se publicará en:";
        listaGanadores.textColor=[UIColor blackColor];
        listaGanadores.font = FONT_BEBAS(15.0f);
        listaGanadores.textAlignment=NSTextAlignmentCenter;

        [self showCountdown:contenedorView forDate:[utils stringToDate:[[json valueForKey:@"party"] valueForKey:@"date"]]];
    }
    else {
        UIImageView *imagen_has_ganado = [[UIImageView alloc] initWithFrame:CGRectMake(164, 107, 123, 73)];
        [imagen_has_ganado setImage:[UIImage imageNamed:@"7_icon_PREMIADO.png"]];
        [contenedorView addSubview:imagen_has_ganado];
        UILabel *ganadores = [[UILabel alloc] initWithFrame:CGRectMake(24, 188, 248, 21)];
        [contenedorView addSubview:ganadores];
        ganadores.text=@"Ganadores";
        ganadores.textColor=[UIColor grayColor];
        ganadores.font = FONT_BEBAS(15.0f);
        ganadores.textAlignment=NSTextAlignmentCenter;
        
        UILabel *separador_ganador = [[UILabel alloc] initWithFrame:CGRectMake(24, 193, 248, 21)];
        [contenedorView addSubview:separador_ganador];
        separador_ganador.text=@"_____________________________";
        separador_ganador.textColor=[UIColor blackColor];
        separador_ganador.font = FONT_BEBAS(15.0f);
        separador_ganador.textAlignment=NSTextAlignmentCenter;
        int y = 218;
        for(NSDictionary* j in [json objectForKey:@"winners"]){
            UILabel *primer_ganador = [[UILabel alloc] initWithFrame:CGRectMake(24, y, 248, 21)];
            [contenedorView addSubview:primer_ganador];
            primer_ganador.text=[j valueForKey:@"name"];
            primer_ganador.textColor=[UIColor blackColor];
            primer_ganador.font = FONT_BEBAS(15.0f);
            primer_ganador.textAlignment=NSTextAlignmentCenter;
            
            UILabel *separador_ganador2 = [[UILabel alloc] initWithFrame:CGRectMake(24, y+5, 248, 21)];
            [contenedorView addSubview:separador_ganador2];
            separador_ganador2.text=@"_____________________________";
            separador_ganador2.textColor=[UIColor grayColor];
            separador_ganador2.font = FONT_BEBAS(15.0f);
            separador_ganador2.textAlignment=NSTextAlignmentCenter;
            y = y +30;
        }
        
        /*NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *id_artist =[f numberFromString:[json objectForKey:@"id"]];
        [buttonActualidad setTag:[id_artist intValue]];*/
        
        UIImageView *desliza_para_eliminar = [[UIImageView alloc] initWithFrame:CGRectMake(15, y+20, 268, 28)];
        [desliza_para_eliminar setImage:[UIImage imageNamed:@"7_button_DESLIZA_ELIMINAR.png"]];
        [contenedorView addSubview:desliza_para_eliminar];
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(desliza_eliminar:)];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [desliza_para_eliminar addGestureRecognizer:swipeRight];
        desliza_para_eliminar.userInteractionEnabled=YES;
        
        CGRect newFrame = contenedorView.frame;
        
        newFrame.size.height = y+60;
        [contenedorView setFrame:newFrame];
    }
    
    [self autoHeight];
}

- (void) autoHeight{
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in _scrollView.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    [_scrollView setContentSize:(CGSizeMake(320, scrollViewHeight))];
}


- (void)desliza_eliminar:(UISwipeGestureRecognizer *)swipe {
    sesion *s = [sesion sharedInstance];
    NSNumber *n = [[NSNumber alloc] initWithInt:swipe.view.tag];
    [[raffle_dao sharedInstance] deleteParticipant:s.codigo_conexion item_id:n y:^(NSArray *sorteos, NSError *error) {
        if (!error) {
            
        } else {
            // Error processing
            NSLog(@"Error al recoger parties places: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
    }];
}

- (void)showCountdown:(UIView*)contenedor forDate: (NSDate*)fecha
{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
     NSUInteger unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
     NSDateComponents *components = [gregorian components:unitFlags fromDate:[NSDate date] toDate:fecha options:0];
     NSInteger day = [components day];
     NSInteger hour = [components hour];
     NSInteger minute = [components minute];
    NSString *digitoS1 = @"0";
    NSString *digitoS2 = @"0";
    NSString *digitoS3 = @"0";
    NSString *digitoS4 = @"0";
    NSString *digitoS5 = @"0";
    NSString *digitoS6 = @"0";
    if(day<10){
        digitoS2 = [NSString stringWithFormat:@"%d", day];
    }
    else{
        digitoS2 = [NSString stringWithFormat: @"%d", day %10];
        day = day/10;
        digitoS1 = [NSString stringWithFormat: @"%d", day %10];
    }
    if(hour<10){
        digitoS4 = [NSString stringWithFormat:@"%d", hour];
    }
    else{
        digitoS4 = [NSString stringWithFormat: @"%d", hour %10];
        hour = hour/10;
        digitoS3 = [NSString stringWithFormat: @"%d", hour %10];
    }
    if(minute<10){
        digitoS6 = [NSString stringWithFormat:@"%d", minute];
    }
    else{
        digitoS6 = [NSString stringWithFormat: @"%d", minute % 10];
        minute = minute/10;
        digitoS5 = [NSString stringWithFormat: @"%d", minute % 10];
    }
    
    UIView *contenedorView=[[UIView alloc]initWithFrame:CGRectMake(60, 212, 174, 70)];
    [contenedorView setBackgroundColor:[UIColor whiteColor]];
    [contenedor addSubview:contenedorView];
    
    UIImageView *imagen_countdown = [[UIImageView alloc] initWithFrame:CGRectMake(8, 11, 160, 54)];
    [imagen_countdown setImage:[UIImage imageNamed:@"countdown.png"]];
    [contenedorView addSubview:imagen_countdown];

    UILabel *digito1 = [[UILabel alloc] initWithFrame:CGRectMake(9, 29, 25, 32)];
    [contenedorView addSubview:digito1];
    digito1.text=digitoS1;
    digito1.textColor=[UIColor whiteColor];
    digito1.font = FONT_BEBAS(30.0f);
    digito1.textAlignment=NSTextAlignmentCenter;
    UILabel *digito2 = [[UILabel alloc] initWithFrame:CGRectMake(33, 29, 25, 32)];
    [contenedorView addSubview:digito2];
    digito2.text=digitoS2;
    NSLog(@"DIGITO 2 %@",digitoS2);
    digito2.textColor=[UIColor whiteColor];
    digito2.font = FONT_BEBAS(30.0f);
    digito2.textAlignment=NSTextAlignmentCenter;
    
    UILabel *digito3 = [[UILabel alloc] initWithFrame:CGRectMake(63, 29, 25, 32)];
    [contenedorView addSubview:digito3];
    digito3.text=digitoS3;
    digito3.textColor=[UIColor whiteColor];
    digito3.font = FONT_BEBAS(30.0f);
    digito3.textAlignment=NSTextAlignmentCenter;

    UILabel *digito4 = [[UILabel alloc] initWithFrame:CGRectMake(87, 29, 25, 32)];
    [contenedorView addSubview:digito4];
    digito4.text=digitoS4;
    digito4.textColor=[UIColor whiteColor];
    digito4.font = FONT_BEBAS(30.0f);
    digito4.textAlignment=NSTextAlignmentCenter;
    NSLog(@"DIGITO 4 %@",digitoS4);
    
    UILabel *digito5 = [[UILabel alloc] initWithFrame:CGRectMake(118, 29, 25, 32)];
    [contenedorView addSubview:digito5];
    digito5.text=digitoS5;
    digito5.textColor=[UIColor whiteColor];
    digito5.font = FONT_BEBAS(30.0f);
    digito5.textAlignment=NSTextAlignmentCenter;
    
    UILabel *digito6 = [[UILabel alloc] initWithFrame:CGRectMake(142, 29, 25, 32)];
    [contenedorView addSubview:digito6];
    digito6.text=digitoS6;
    digito6.textColor=[UIColor whiteColor];
    digito6.font = FONT_BEBAS(30.0f);
    digito6.textAlignment=NSTextAlignmentCenter;
    
    UIView *barra1=[[UIView alloc]initWithFrame:CGRectMake(14, 44, 15, 1)];
    [barra1 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra1];
    
    UIView *barra2=[[UIView alloc]initWithFrame:CGRectMake(37, 44, 15, 1)];
    [barra2 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra2];
    
    UIView *barra3=[[UIView alloc]initWithFrame:CGRectMake(69, 44, 15, 1)];
    [barra3 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra3];
    
    UIView *barra4=[[UIView alloc]initWithFrame:CGRectMake(93, 44, 15, 1)];
    [barra4 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra4];
    
    UIView *barra5=[[UIView alloc]initWithFrame:CGRectMake(122, 44, 15, 1)];
    [barra5 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra5];
    
    UIView *barra6=[[UIView alloc]initWithFrame:CGRectMake(147, 44, 15, 1)];
    [barra6 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra6];
}

- (IBAction)back:(id)sender {
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


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
#import "sesion.h"
#import "party_dao.h"
#import "register_dao.h"
#import "utils.h"
#import "actualidadIndexViewController.h"
#import "sorteosIndexViewController.h"

@interface agendaIndexViewController ()
@property (weak, nonatomic) IBOutlet UILabel *fecha_label;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewCalendar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity_indicator;
@property (weak, nonatomic) IBOutlet UIButton *button_coordenadas;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *altura_scroll;
@property (weak, nonatomic) IBOutlet UIView *view_scroll;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;

@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation agendaIndexViewController

int numero_eventos = 0;
#define limit_paginate ((int) 10)
NSString *date = @"";

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
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 118;
    
    NSDate *today = [NSDate date];
    _fecha_label.text = [utils fechaConFormatoTituloAgenda:today];
    _fecha_label.font = FONT_BEBAS(13.0f);
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents* components = [[NSDateComponents alloc] init];
    components.day = 1;
    for(int dia=0;dia<60;dia++){
        [self mostrar_dia_calendario_lateral:today posicion:dia];
        today = [calendar dateByAddingComponents: components toDate: today options: 0];
    }
    [self autoWidthCalendar];
    
    _scrollView.delegate = self;
    sesion *s = [sesion sharedInstance];
    NSNumber *desde = [NSNumber numberWithInteger:numero_eventos];
    NSNumber *hasta = [NSNumber numberWithInteger:limit_paginate];
    [_activity_indicator startAnimating];
    _activity_indicator.hidden = FALSE;
    [[party_dao sharedInstance] getPartiesPlaces:s.codigo_conexion date:[NSDate date] limit:hasta page:desde y:^(NSArray *places, NSError *error) {
        if (!error) {
            for (NSDictionary *JSONnoteData in places) {
                [self mostrar_evento:JSONnoteData];
            }
            if([places count]==0){
                [self mostrar_no_se_han_encontrado_eventos];
            }
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
        [_activity_indicator stopAnimating];
        _activity_indicator.hidden = TRUE;
    }];
    
    [self autoHeight];
    
    if(s.latitude!=nil && s.latitude!=0){
        [self shakeView];
    }
    else{
        _button_coordenadas.hidden = TRUE;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    numero_eventos = 0;
}

- (void) mostrar_no_se_han_encontrado_eventos{
    for (UIView* v in _view_scroll.subviews){
        [v removeFromSuperview];
    }
    UITextView *no_places = [[UITextView alloc] initWithFrame:CGRectMake(0, 50, 320, 100)];
    no_places.backgroundColor = [UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1];
    no_places.text=[NSString stringWithFormat:@"%@\n%@",@"NO SE HAN ENCONTRADO EVENTOS",@"PARA ESTA FECHA"];
    [no_places setTextAlignment:NSTextAlignmentCenter];
    no_places.textColor=[UIColor blackColor];
    no_places.font = FONT_BEBAS(25.0f);
    [_view_scroll addSubview:no_places];
    [_view_scroll bringSubviewToFront:no_places];

}

-(void)shakeView {
    
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.08];
    [shake setRepeatCount:10];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(_button_coordenadas.center.x - 3,_button_coordenadas.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(_button_coordenadas.center.x + 3, _button_coordenadas.center.y)]];
    [_button_coordenadas.layer addAnimation:shake forKey:@"position"];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_activity_indicator startAnimating];
    sesion *s = [sesion sharedInstance];
    NSNumber *desde = [NSNumber numberWithInteger:numero_eventos];
    NSNumber *hasta = [NSNumber numberWithInteger:limit_paginate];
    NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
    [dfDate setDateFormat:@"dd/mm/yyyy"];
    [_activity_indicator startAnimating];
    _activity_indicator.hidden = FALSE;
    [[party_dao sharedInstance] getPartiesPlaces:s.codigo_conexion date:[dfDate dateFromString:date] limit:hasta page:desde y:^(NSArray *places, NSError *error) {
        if (!error) {
    
            for (NSDictionary *JSONnoteData in places) {
                [self mostrar_evento:JSONnoteData];
            }
            if([places count]==0){
                [self mostrar_no_se_han_encontrado_eventos];
            }
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
        [_activity_indicator stopAnimating];
        _activity_indicator.hidden = TRUE;
    }];
    [self autoHeight];
    [_activity_indicator stopAnimating];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mostrar_evento:(NSDictionary*)json {
    //Las UIViews de agenda
    UIView *agendaView=[[UIView alloc]initWithFrame:CGRectMake(2, 120*numero_eventos , 317, 114)];
    numero_eventos++;
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
    [_view_scroll addSubview:agendaView];
    agendaView.alpha = 0.0;
    agendaView.transform =CGAffineTransformMakeScale(0,0);
    [UIView animateWithDuration:0.5 animations:^{
        agendaView.alpha = 1.0;
        agendaView.transform =CGAffineTransformMakeScale(1.0,1.0);
    }];
}

- (void)mostrar_dia_calendario_lateral:(NSDate*)day posicion:(int) posicion{

    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:day];
    
    [NSLocale availableLocaleIdentifiers];
    _scrollViewCalendar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"5_BACKGROUND_CALENDAR_LATERAL.png"]];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    NSDateFormatter* dfWeekDay = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_es"];
    [df setLocale:locale];
    [df setDateFormat:@"MMMM"];
    [dfWeekDay setLocale:locale];
    [dfWeekDay setDateFormat:@"EEEE"];
    
    UIView *diaView=[[UIView alloc]initWithFrame:CGRectMake(posicion*100, 0, 100, 48)];
    [diaView setBackgroundColor:[UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:0]];
    [_scrollViewCalendar addSubview:diaView];
    UILabel *numeroDia = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 40, 46)];
    numeroDia.tag=1;
    [diaView addSubview:numeroDia];
    numeroDia.text=[NSString stringWithFormat: @"%d", (int)[components day]];
    numeroDia.textColor=[UIColor whiteColor];
    numeroDia.font = FONT_BEBAS(45.0f);
    numeroDia.textAlignment = NSTextAlignmentCenter;
    
    UIButton *buttonDia = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 48)];
    [diaView addSubview:buttonDia];
    
    //Como no le podemos pasar ningún parámetro a la función pero si un entero, le pasamos la diferencia de días desde hoy hasta el día escogido
    buttonDia.tag = posicion;
    [buttonDia addTarget:self action:@selector(agendaSegunDia:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *mes = [[UILabel alloc] initWithFrame:CGRectMake(39, 8, 40, 21)];
    [diaView addSubview:mes];
    
    mes.text=[[df stringFromDate:day] substringWithRange:NSMakeRange(0, 3)];
    mes.textColor=[UIColor blackColor];
    mes.font = FONT_BEBAS(24.0f);
    mes.alpha = 0.6;
    
    UILabel *diaSemana = [[UILabel alloc] initWithFrame:CGRectMake(40, 25, 55, 21)];
    diaSemana.tag=1;
    [diaView addSubview:diaSemana];
    diaSemana.text=[dfWeekDay stringFromDate:day];
    diaSemana.textColor=[UIColor whiteColor];
    diaSemana.font = FONT_BEBAS(16.0f);
    
    UIImageView *separador = [[UIImageView alloc] initWithFrame:CGRectMake(98, 7, 2, 35)];
    [separador setImage:[UIImage imageNamed:@"5_SEPARACION_FECHAS.png"]];
    separador.alpha = 0.2;
    [diaView addSubview:separador];
}

-(void)agendaSegunDia:(UIButton*)sender
{
    for (UIView *v in _scrollViewCalendar.subviews){
        for (UIView *v2 in v.subviews){
            if(v2.tag==1 && [v2 isKindOfClass:[UILabel class]]){
                UILabel *v3 = (UILabel*)v2;
                v3.textColor=[UIColor whiteColor];
            }
        }
    }
    for (UIView* v in sender.superview.subviews){
        if(v.tag==1 && [v isKindOfClass:[UILabel class]]){
            UILabel *v2 = (UILabel*)v;
            v2.textColor=[UIColor colorWithRed:0.0/255.0f green:255.0/255.0f blue:222.0/255.0f alpha:1];
        }
    }
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents* components = [[NSDateComponents alloc] init];
    components.day = sender.tag;
    NSDate* newDate = [calendar dateByAddingComponents: components toDate: [NSDate date] options: 0];
    NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
    [dfDate setDateFormat:@"dd/mm/yyyy"];
    [self inicializarVista];
    date = [dfDate stringFromDate:newDate];
    _fecha_label.text = [utils fechaConFormatoTituloAgenda:newDate];
    
    NSNumber *hasta = [NSNumber numberWithInteger:limit_paginate];
    sesion *s = [sesion sharedInstance];
    [_activity_indicator startAnimating];
    _activity_indicator.hidden = FALSE;
     [[party_dao sharedInstance] getPartiesPlaces:s.codigo_conexion date:newDate limit:hasta page:nil y:^(NSArray *places, NSError *error) {
     if (!error) {
     
         for (NSDictionary *JSONnoteData in places) {
             [self mostrar_evento:JSONnoteData];
         }
         if([places count] == 0 ){
             [self mostrar_no_se_han_encontrado_eventos];
         }
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
         [_activity_indicator stopAnimating];
         _activity_indicator.hidden = TRUE;
     }];
}

-(void)inicializarVista{
    NSArray *viewsToRemove = [_view_scroll subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    numero_eventos = 0;
}

- (void) autoHeight{
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in _scrollView.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    [_scrollView setContentSize:(CGSizeMake(320, scrollViewHeight))];
}

- (void) autoWidthCalendar{
    CGFloat scrollViewWidth = 0.0f;
    for (UIView* view in _scrollViewCalendar.subviews)
    {
        scrollViewWidth += view.frame.size.width;
    }
    [_scrollViewCalendar setContentSize:(CGSizeMake(scrollViewWidth, 48))];
}


- (IBAction)guardar_coordenadas:(id)sender {
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"SET COORDENATES");
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * latNumber = [[NSNumber alloc] initWithFloat:newLocation.coordinate.latitude];
    NSNumber * longNumber = [[NSNumber alloc] initWithFloat:newLocation.coordinate.longitude];
    
    sesion *s = [sesion sharedInstance];
    [[register_dao sharedInstance] setCoordinates:s.codigo_conexion latitude:latNumber longitude:longNumber y:^(NSArray *party, NSError *error){
        if (!error) {
            s.latitude = latNumber;
            s.longitude = longNumber;
        } else {
            // Error hacer el like
        }
    }];
    
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

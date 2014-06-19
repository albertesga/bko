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
#import "sesion.h"
#import "party_dao.h"
#import "utils.h"
#import "register_dao.h"
#import "actualidadIndexViewController.h"
#import "agendaIndexViewController.h"
#import "sorteosIndexViewController.h"
#import "sinConexionViewController.h"

@interface agendaArtistasIndexViewController ()
@property (weak, nonatomic) IBOutlet UILabel *agenda_label;
@property (weak, nonatomic) IBOutlet UILabel *fecha_label;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewCalendar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity_indicator;
@property (weak, nonatomic) IBOutlet UIView *view_scroll;
@property (weak, nonatomic) IBOutlet UIButton *button_coordenadas;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *altura_scroll;

@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation agendaArtistasIndexViewController

NSNumber* desde_artistas = 0;
int numero_artistas = 0;
NSString *date_artistas =@"";

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

    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 180;
    self.revealViewController.delegate = self;
    
    NSDate *today = [NSDate date];
    
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
    NSNumber *hasta = [NSNumber numberWithInteger:[desde_artistas intValue]+10];
    [_activity_indicator startAnimating];
    _activity_indicator.hidden = FALSE;
    components.day = _dia;
    NSDate* fecha_inicio = [calendar dateByAddingComponents: components toDate: [NSDate date] options: 0];
    _fecha_label.text = [utils fechaConFormatoTituloAgenda:fecha_inicio];
    [[party_dao sharedInstance] getPartiesArtists:s.codigo_conexion date:fecha_inicio limit:hasta page:desde_artistas y:^(NSArray *places, NSError *error) {
        if (!error) {
        
            desde_artistas = [NSNumber numberWithInt:([desde_artistas integerValue] + [places count])];
            for (NSDictionary *JSONnoteData in places) {
                [self mostrar_artista:JSONnoteData];
            }
            if([places count]==0){
                [self mostrar_no_se_han_encontrado_artistas];
            }
        } else {
            // Error processing
            [utils controlarErrores:error];
        }
        [_activity_indicator stopAnimating];
        _activity_indicator.hidden = TRUE;
    }];
    
    if([s.latitude intValue] == 0){
        [self shakeView];
    }
    else{
        _button_coordenadas.hidden = TRUE;
    }

}
- (IBAction)irEventos:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    agendaIndexViewController *agendaController =
    [storyboard instantiateViewControllerWithIdentifier:@"agendaIndexViewController"];
    agendaController.dia = _dia;
    [self.navigationController pushViewController:agendaController animated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    [self.navigationController viewControllers];
    if ([[self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2] isKindOfClass:[agendaIndexViewController class]]){
        NSMutableArray *allControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        [allControllers removeObjectAtIndex:[allControllers count] - 2];
        [self.navigationController setViewControllers:allControllers animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    numero_artistas = 0;
    if(!_degradado_menu.hidden){
        [self.radialMenu buttonsWillAnimateFromButton:_menu_button withFrame:self.menu_button.frame inView:self.view];
        [UIView transitionWithView:_degradado_menu
                          duration:0.8
                           options:
         UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
        _degradado_menu.hidden = true;
    }
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        self.view.userInteractionEnabled = YES;
    } else {
        self.view.userInteractionEnabled = NO;
    }
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{    if(position == FrontViewPositionLeft) {
        self.view.userInteractionEnabled = YES;
    } else {
        self.view.userInteractionEnabled = NO;
    }
}

- (void) mostrar_no_se_han_encontrado_artistas{
    UITextView *no_places = [[UITextView alloc] initWithFrame:CGRectMake(0, 50, 320, 100)];
    [_view_scroll addSubview:no_places];
    no_places.backgroundColor = [UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1];
    no_places.text=[NSString stringWithFormat:@"%@\n%@",@"NO SE HAN ENCONTRADO ARTISTAS",@"PARA ESTA FECHA"];
    [no_places setTextAlignment:NSTextAlignmentCenter];
    no_places.textColor=[UIColor blackColor];
    no_places.font = FONT_BEBAS(25.0f);
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
    sesion *s = [sesion sharedInstance];
    desde_artistas = [NSNumber numberWithInt:([desde_artistas integerValue] + 10)];
     NSNumber *hasta = [NSNumber numberWithInteger:[desde_artistas intValue]+10];
    NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
    [dfDate setDateFormat:@"dd/mm/yyyy"];
    [_activity_indicator startAnimating];
    _activity_indicator.hidden = FALSE;
     [[party_dao sharedInstance] getPartiesArtists:s.codigo_conexion date:[dfDate dateFromString:date_artistas] limit:hasta page:desde_artistas y:^(NSArray *artistas, NSError *error) {
     if (!error) {
     desde_artistas = [NSNumber numberWithInt:([desde_artistas integerValue] + [artistas count])];
         for (NSDictionary *JSONnoteData in artistas) {
                [self mostrar_artista:JSONnoteData];
         }
         if([artistas count]==0){
             [self mostrar_no_se_han_encontrado_artistas];
         }
     } else {
     // Error processing
         [utils controlarErrores:error];
     }
         [_activity_indicator stopAnimating];
         _activity_indicator.hidden = TRUE;
     }];
    for(int dia=0;dia<10;dia++){
        [self mostrar_artista:nil];
    }
    [self autoHeight:false];
}

- (void) mostrar_artista:(NSDictionary*) json{
    int fila = (numero_artistas/3);
    int columna = numero_artistas%3;
    int y = 110*fila + 5;
    int x = 5;
    x = x + 105*columna;

    numero_artistas++;
    //Las UIViews de cada
    UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(x, y, 106, 106)];
    [paintView setBackgroundColor:[UIColor clearColor]];
    [_view_scroll addSubview:paintView];

    UIButton *buttonArtista = [[UIButton alloc] initWithFrame:CGRectMake(3, 3, 100, 100)];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[json objectForKey:@"list_img"]]];
    [buttonArtista setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
    [paintView addSubview:buttonArtista];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *id_artist =[f numberFromString:[[json objectForKey:@"party"] objectForKey:@"id"]];
    [buttonArtista setTag:[id_artist intValue]];

    [buttonArtista addTarget:self action:@selector(detallesAgenda:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imagen_fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(3, 82, 100, 20)];
    [imagen_fondo_box setImage:[UIImage imageNamed:@"FONDO_IMAGEN.png"]];
    [paintView addSubview:imagen_fondo_box];
    
    UILabel *tituloActualidad = [[UILabel alloc] initWithFrame:CGRectMake(5, 82, 100, 21)];
    [paintView addSubview:tituloActualidad];
    tituloActualidad.text=[json valueForKey:@"name"];
    tituloActualidad.textColor=[UIColor whiteColor];
    tituloActualidad.font = FONT_BEBAS(13.0f);
    tituloActualidad.textAlignment=NSTextAlignmentCenter;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    [diaView addSubview:numeroDia];
    numeroDia.text=[NSString stringWithFormat: @"%d", (int)[components day]];
    if(posicion==_dia){
        numeroDia.textColor=[UIColor colorWithRed:0.0/255.0f green:255.0/255.0f blue:222.0/255.0f alpha:1];
    }
    else{
        numeroDia.textColor=[UIColor whiteColor];
    }
    numeroDia.font = FONT_BEBAS(45.0f);
    numeroDia.textAlignment = NSTextAlignmentCenter;
    numeroDia.tag=1;
    UIButton *buttonDia = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 48)];
    [diaView addSubview:buttonDia];
    
    //Como no le podemos pasar ningún parámetro a la función pero si un entero, le pasamos la diferencia de días desde hoy hasta el día escogido
    buttonDia.tag = posicion;
    [buttonDia addTarget:self action:@selector(agendaArtistaSegunDia:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *mes = [[UILabel alloc] initWithFrame:CGRectMake(39, 8, 40, 21)];
    [diaView addSubview:mes];
    
    mes.text=[[df stringFromDate:day] substringWithRange:NSMakeRange(0, 3)];
    mes.textColor=[UIColor blackColor];
    mes.font = FONT_BEBAS(24.0f);
    mes.alpha = 0.6;
    
    UILabel *diaSemana = [[UILabel alloc] initWithFrame:CGRectMake(40, 25, 55, 21)];
    [diaView addSubview:diaSemana];
    diaSemana.text=[dfWeekDay stringFromDate:day];
    if(posicion==_dia){
        diaSemana.textColor=[UIColor colorWithRed:0.0/255.0f green:255.0/255.0f blue:222.0/255.0f alpha:1];
    }
    else{
        diaSemana.textColor=[UIColor whiteColor];
    }
    diaSemana.tag=1;
    diaSemana.font = FONT_BEBAS(16.0f);
    
    UIImageView *separador = [[UIImageView alloc] initWithFrame:CGRectMake(98, 7, 2, 35)];
    [separador setImage:[UIImage imageNamed:@"5_SEPARACION_FECHAS.png"]];
    separador.alpha = 0.2;
    [diaView addSubview:separador];
}

-(void)agendaArtistaSegunDia:(UIButton*)sender
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
    _dia = sender.tag;
    NSDate* newDate = [calendar dateByAddingComponents: components toDate: [NSDate date] options: 0];
    NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
    [dfDate setDateFormat:@"dd-mm-yyyy"];
    [self inicializarVista];
    date_artistas = [dfDate stringFromDate:newDate];
    _fecha_label.text = [utils fechaConFormatoTituloAgenda:newDate];
    desde_artistas = [NSNumber numberWithInt:([desde_artistas integerValue] + 10)];
    sesion *s = [sesion sharedInstance];
    //NSNumber *hasta = [NSNumber numberWithInteger:[desde_artistas intValue]+10];
    [_activity_indicator startAnimating];
    _activity_indicator.hidden = FALSE;
     [[party_dao sharedInstance] getPartiesArtists:s.codigo_conexion date:newDate limit:nil page:desde_artistas y:^(NSArray *artistas, NSError *error) {
     if (!error) {
         for (NSDictionary *JSONnoteData in artistas) {
                [self mostrar_artista:JSONnoteData];
         }
         if([artistas count]==0){
             [self mostrar_no_se_han_encontrado_artistas];
         }
     } else {
     // Error processing
         [utils controlarErrores:error];
     }
         [_activity_indicator stopAnimating];
         _activity_indicator.hidden = TRUE;
     }];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
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

- (IBAction)guardar_coordenadas:(id)sender {
    [locationManager startUpdatingLocation];
}

- (void) autoHeight:(BOOL)primera{
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in _view_scroll.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    if(primera){
        self.altura_scroll.constant = scrollViewHeight/3+54;
    }
    else{
        self.altura_scroll.constant = scrollViewHeight/3;
    }
}

- (void) autoWidthCalendar{
    CGFloat scrollViewWidth = 0.0f;
    for (UIView* view in _scrollViewCalendar.subviews)
    {
        scrollViewWidth += view.frame.size.width;
    }
    [_scrollViewCalendar setContentSize:(CGSizeMake(scrollViewWidth, 48))];
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

-(void)inicializarVista{
    NSArray *viewsToRemove = [_view_scroll subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    desde_artistas = 0;
    numero_artistas = 0;
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
        _scrollViewCalendar.userInteractionEnabled = NO;
        _degradado_menu.hidden = false;
    }
    else{
        _scrollViewCalendar.userInteractionEnabled = YES;
        _degradado_menu.hidden = true;
    }
}

#pragma mark - radial menu delegate methods
- (NSInteger) numberOfItemsInRadialMenu:(ALRadialMenu *)radialMenu {
    return 2;
}


- (NSInteger) arcSizeForRadialMenu:(ALRadialMenu *)radialMenu {
    //Tamaño en grados de lo que ocupa el menu
    return 40;
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
			
		}
	}
}

- (void)itemsWillDisapearIntoButton:(UIButton *)button{
    _degradado_menu.hidden = true;
}

- (IBAction)menuButton:(id)sender {
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

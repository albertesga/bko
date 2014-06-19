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
#import "sinConexionViewController.h"
#import "utils.h"
#import "articles_dao.h"
#import "constructorVistas.h"
#import "fichaViewController.h"

@interface planesIndexViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (strong, nonatomic) IBOutlet UIView *vista;

@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@property (weak, nonatomic) IBOutlet UITextField *textViewBuscar;
@property (weak, nonatomic) IBOutlet UIView *viewBuscar;

@end

@implementation planesIndexViewController

BOOL menu_user_abierto;

int numero_resultados_planes = 0;
NSString* ultima_busqueda_planes = @"";
#define DEVICE_SIZE [[[[UIApplication sharedApplication] keyWindow] rootViewController].view convertRect:[[UIScreen mainScreen] bounds] fromView:nil].size

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
    [self conectado];
    
    menu_user_abierto = false;
    UILabel *no_hay_eventos = [[UILabel alloc] initWithFrame:CGRectMake(20, 320, 280, 21)];
    no_hay_eventos.font = FONT_BEBAS(16.0f);
    no_hay_eventos.text = @"SELECCIONA UN DÍA CON PLAN PARA VERLO EN DETALLE";
    no_hay_eventos.textAlignment = NSTextAlignmentCenter;
    no_hay_eventos.textColor = [UIColor colorWithRed:163.0/255.0f green:163.0/255.0f blue:163.0/255.0f alpha:1];
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    [self.vista addSubview:no_hay_eventos];
    
    [_viewBuscar setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.textViewBuscar.delegate=self;
    
    CKCalendarView *calendar = [[CKCalendarView alloc] init];
    [_vista addSubview:calendar];
    calendar.delegate = self;
    
    
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 180;
    self.revealViewController.delegate = self;
    sesion *s = [sesion sharedInstance];
    [[party_dao sharedInstance] getPlans:s.codigo_conexion date:[NSDate date] y:^(NSArray *places, NSError *error) {
        if (!error) {
            NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
            [dfDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            for (NSDictionary *JSONnoteData in places) {
                
                NSDate *date2 = [dfDate dateFromString:[[JSONnoteData objectForKey:@"party"] objectForKey:@"start_date"]];
                
                NSCalendar *nscalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [nscalendar components:(NSHourCalendarUnit) fromDate:date2];
                if([components hour]<=4){
                    NSDateComponents *comps = [NSDateComponents new];
                    comps.day = -1;
                    date2 = [nscalendar dateByAddingComponents:comps toDate:date2 options:0];
                }
                [calendar setDateWithEvent:date2];
            }
            [calendar reloadData];

        } else {
            [utils controlarErrores:error];
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    if ([[self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2] isKindOfClass:[self class]]){
        NSMutableArray *allControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        [allControllers removeObjectAtIndex:[allControllers count] - 2];
        [self.navigationController setViewControllers:allControllers animated:NO];
    }
}

-(void)resetView
{
    [self.view setNeedsDisplay];
    self.view=nil;
    [self viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self resetView];
}

- (void)viewWillDisappear:(BOOL)animated{
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
    for (UIView* v in [self.view subviews]){
        if ([v tag]==50){
            [v removeFromSuperview];
        }
    }
    _viewBuscar.hidden = TRUE;
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        _vista.userInteractionEnabled = YES;
        menu_user_abierto = NO;
    } else {
        _vista.userInteractionEnabled = NO;
        menu_user_abierto = YES;
    }
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        _vista.userInteractionEnabled = YES;
        menu_user_abierto = NO;
    } else {
        _vista.userInteractionEnabled = NO;
        menu_user_abierto = YES;
    }
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    if (!menu_user_abierto){
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
                
                NSDate *date2 = [dfDate dateFromString:[[JSONnoteData objectForKey:@"party"] objectForKey:@"start_date"]];
                
                NSCalendar *nscalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [nscalendar components:(NSHourCalendarUnit) fromDate:date2];
                if([components hour]<=4){
                    NSDateComponents *comps = [NSDateComponents new];
                    comps.day = -1;
                    date2 = [nscalendar dateByAddingComponents:comps toDate:date2 options:0];
                }
                
                if([calendar date:date isSameDayAsDate:date2]){
                    [self mostrar_evento:JSONnoteData];
                }
                
            }
            [calendar reloadDataWithoutSelectedData];
            
        } else {
            [utils controlarErrores:error];
        }
    }];
    }
}

- (void)calendar:(CKCalendarView *)calendar didChangeToMonth:(NSDate *)date {
    if (!menu_user_abierto){
    sesion *s = [sesion sharedInstance];
    [[party_dao sharedInstance] getPlans:s.codigo_conexion date:date y:^(NSArray *places, NSError *error) {
        if (!error) {
            NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
            [dfDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            for (NSDictionary *JSONnoteData in places) {
                NSDate *date2 = [dfDate dateFromString:[[JSONnoteData objectForKey:@"party"] objectForKey:@"start_date"]];
                
                NSCalendar *nscalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [nscalendar components:(NSHourCalendarUnit) fromDate:date2];
                if([components hour]<=4){
                    NSDateComponents *comps = [NSDateComponents new];
                    comps.day = -1;
                    date2 = [nscalendar dateByAddingComponents:comps toDate:date2 options:0];
                }
                [calendar setDateWithEvent:date2];
                
                
                //[calendar setDateWithEvent:[dfDate dateFromString:[[JSONnoteData objectForKey:@"party"] objectForKey:@"start_date"]]];
            }
            [calendar reloadData];
            
        } else {
            [utils controlarErrores:error];
        }
    }];
    }
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
    UIView *cuandoView=[[UIView alloc]initWithFrame:CGRectMake(110, 7, 200, 20)];
    [cuandoView setBackgroundColor:[UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1]];
    [agendaView addSubview:cuandoView];
    UILabel *nombreAgenda = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 120, 21)];
    [cuandoView addSubview:nombreAgenda];
    nombreAgenda.text=[[json objectForKey:@"party"] objectForKey:@"list_name"];
    nombreAgenda.textColor=[UIColor whiteColor];
    nombreAgenda.font = FONT_BEBAS(17.0f);
    
    UIImageView *icono_reloj = [[UIImageView alloc] initWithFrame:CGRectMake(153, 4, 11, 11)];
    [icono_reloj setImage:[UIImage imageNamed:@"5_icon_TIEMPO.png"]];
    [cuandoView addSubview:icono_reloj];
    
    UILabel *cuandoAgenda = [[UILabel alloc] initWithFrame:CGRectMake(167, 0, 43, 21)];
    [cuandoView addSubview:cuandoAgenda];
    
    NSString* date = [[[json objectForKey:@"party"] objectForKey:@"start_date"] substringFromIndex:11];
    cuandoAgenda.text= [date substringToIndex:5];
    cuandoAgenda.textColor=[UIColor whiteColor];
    cuandoAgenda.font = FONT_BEBAS(17.0f);
    
    UIImageView *icono_donde = [[UIImageView alloc] initWithFrame:CGRectMake(115, 89, 13, 18)];
    [icono_donde setImage:[UIImage imageNamed:@"5_ICONO_PUNTO.png"]];
    [agendaView addSubview:icono_donde];
    
    UITextView *descripcionAgenda = [[UITextView alloc] initWithFrame:CGRectMake(108, 27, 200, 57)];
    [descripcionAgenda setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    [agendaView addSubview:descripcionAgenda];
    descripcionAgenda.text=[[json objectForKey:@"party"] objectForKey:@"list_description"];
    descripcionAgenda.textColor=[UIColor blackColor];
    descripcionAgenda.font = FONT_BEBAS(16.0f);
    descripcionAgenda.editable = NO;
    descripcionAgenda.scrollEnabled = NO;
    
    UILabel *dondeAgenda = [[UILabel alloc] initWithFrame:CGRectMake(132, 89, 142, 21)];
    [agendaView addSubview:dondeAgenda];
    dondeAgenda.text=[json objectForKey:@"name"];
    dondeAgenda.textColor=[UIColor blackColor];
    dondeAgenda.font = FONT_BEBAS(20.0f);
    agendaView.tag = 2;
    [_vista addSubview:agendaView];
    
    UIButton *buttonEvento2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 317, 114)];
    [agendaView addSubview:buttonEvento2];
    [buttonEvento2 addTarget:self action:@selector(detallesAgenda:) forControlEvents:UIControlEventTouchUpInside];
    [buttonEvento2 setTag:[id_artist intValue]];
    
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
            
            agendaIndexViewController *agendaController =
            [storyboard instantiateViewControllerWithIdentifier:@"agendaIndexViewController"];
            
            [self.navigationController pushViewController:agendaController animated:YES];
			
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

- (IBAction)buscar:(id)sender {
    _textViewBuscar.text = @"";
    ultima_busqueda_planes = @"";
    /*if(_scrollView.userInteractionEnabled){
        _scrollView.userInteractionEnabled = FALSE;
    }
    else{
        _scrollView.userInteractionEnabled = TRUE;
    }*/
    CGRect newFrame = _viewBuscar.frame;
    newFrame.origin.y = DEVICE_SIZE.height - 140;
    newFrame.size.height = 54;
    _viewBuscar.frame = newFrame;
    if(_viewBuscar.hidden){
        _viewBuscar.hidden = FALSE;
    }
    else{
        _viewBuscar.hidden = TRUE;
    }
    for (UIView* v in [self.view subviews]){
        if ([v tag]==50){
            [v removeFromSuperview];
            _viewBuscar.hidden = TRUE;
        }
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.textViewBuscar) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //hides keyboard when another part of layout was touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
    for (UIView* v in [self.view subviews]){
        if ([v tag]==50){
            [v removeFromSuperview];
            
        }
    }
    _viewBuscar.hidden = TRUE;
    _vista.userInteractionEnabled = TRUE;
}

- (IBAction)textFieldDidBeginEditing:(id)sender {
    CGRect newFrame = _viewBuscar.frame;
    newFrame.origin.y = DEVICE_SIZE.height - 310;
    [_vista bringSubviewToFront:_viewBuscar];
    _viewBuscar.frame = newFrame;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender
{
    if(![ultima_busqueda_planes isEqualToString:_textViewBuscar.text]){
        [self buscar];
        CGRect newFrame = _viewBuscar.frame;
        newFrame.origin.y = DEVICE_SIZE.height - 270;
        newFrame.size.height = 180;
        _viewBuscar.frame = newFrame;
    }
}

- (void) buscar
{
    sesion *s = [sesion sharedInstance];
    if(![ultima_busqueda_planes isEqualToString:_textViewBuscar.text]){
        ultima_busqueda_planes = _textViewBuscar.text;
        [[articles_dao sharedInstance] search:s.codigo_conexion q:_textViewBuscar.text limit:@5 page:@0 y:^(NSArray *articles, NSError *error) {
            if (!error) {
                UIScrollView* scrollViewSearch = [[UIScrollView alloc] initWithFrame:CGRectMake(0, DEVICE_SIZE.height - 54 - 166, 320, 130)];
                scrollViewSearch.tag = 50;
                [scrollViewSearch setBackgroundColor: [UIColor colorWithRed:37.0/255.0f green:37.0/255.0f blue:37.0/255.0f alpha:1]];
                int i = 0;
                NSValue *irArtistas = [NSValue valueWithPointer:@selector(verArtista:)];
                NSValue *irSitio = [NSValue valueWithPointer:@selector(verSitio:)];
                NSValue *irSello = [NSValue valueWithPointer:@selector(verSello:)];
                for (NSDictionary *JSONnoteData in articles) {
                    [constructorVistas dibujarResultadoEnPosicion:JSONnoteData en:scrollViewSearch posicion:i selectorArtista:irArtistas selectorSitio:irSitio selectorSello:irSello controllerBase:self];
                    i++;
                    numero_resultados_planes++;
                }
                
                [self autoWidthScrollView:scrollViewSearch];
                [self.view addSubview:scrollViewSearch];
                numero_resultados_planes = 0;
                
            } else {
            }
        }];
    }
}

- (void) autoWidthScrollView:(UIScrollView*)scrollViewBusqueda{
    CGFloat scrollViewWidth = 0.0f;
    for (UIView* view in scrollViewBusqueda.subviews)
    {
        scrollViewWidth += view.frame.size.width+10;
    }
    [scrollViewBusqueda setContentSize:(CGSizeMake(scrollViewWidth, 130))];
}

-(void)verSitio:(UIButton*)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    fichaViewController *fichaController =
    [storyboard instantiateViewControllerWithIdentifier:@"fichaViewController"];
    NSInteger id_art = sender.tag;
    fichaController.id_card = id_art;
    fichaController.kind = [utils getKind:@"Sitio"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:fichaController animated:YES ];
    
}

-(void)verSello:(UIButton*)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    fichaViewController *fichaController =
    [storyboard instantiateViewControllerWithIdentifier:@"fichaViewController"];
    NSInteger id_art = sender.tag;
    fichaController.id_card = id_art;
    fichaController.kind = [utils getKind:@"Sello"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:fichaController animated:YES ];
    
}

-(void)verArtista:(UIButton*)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    fichaViewController *fichaController =
    [storyboard instantiateViewControllerWithIdentifier:@"fichaViewController"];
    NSInteger id_art = sender.tag;
    fichaController.id_card = id_art;
    fichaController.kind = [utils getKind:@"Artist"];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:fichaController animated:YES ];
    
    
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

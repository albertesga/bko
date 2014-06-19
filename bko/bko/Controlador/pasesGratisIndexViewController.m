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
#import "sinConexionViewController.h"
#import "articles_dao.h"
#import "constructorVistas.h"
#import "fichaViewController.h"
#import "party_dao.h"
#import "agendaDetalleViewController.h"

@interface pasesGratisIndexViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@property (weak, nonatomic) IBOutlet UITextField *textViewBuscar;
@property (weak, nonatomic) IBOutlet UIView *viewBuscar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *altura_scroll;
@property (weak, nonatomic) IBOutlet UIView *modal_qr;
@property (weak, nonatomic) IBOutlet UILabel *tituloQR;
@property (weak, nonatomic) IBOutlet UILabel *ensenyaQR;
@property (weak, nonatomic) IBOutlet UILabel *mensajeQR;
@property (weak, nonatomic) IBOutlet UIImageView *imageQR;
@property (weak, nonatomic) IBOutlet UILabel *condicionesTitulo;
@property (weak, nonatomic) IBOutlet UIView *modal_condiciones;
@property (weak, nonatomic) IBOutlet UITextView *text_condiciones;
@property (weak, nonatomic) IBOutlet UIView *scrollView;

@end

@implementation pasesGratisIndexViewController

int numero_pases = 0;
#define limit_paginate ((int) 6)
int numero_resultados_pases = 0;
NSString* ultima_busqueda_pases = @"";
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
    
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 180;
    self.revealViewController.delegate = self;
    
    [_viewBuscar setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.textViewBuscar.delegate=self;
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    UILabel *no_hay_pases = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 21)];
    _tituloQR.font = FONT_BEBAS(18.0f);
    _ensenyaQR.font = FONT_BEBAS(15.0f);
    _mensajeQR.font = FONT_BEBAS(14.0f);
    _text_condiciones.font = FONT_BEBAS(13.0f);
    _condicionesTitulo.font = FONT_BEBAS(18.0f);
    no_hay_pases.font = FONT_BEBAS(16.0f);
    no_hay_pases.text = @"NO HAY PASES GRATIS";
    no_hay_pases.textAlignment = NSTextAlignmentCenter;
    no_hay_pases.textColor = [UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1];
    [_scrollView addSubview:no_hay_pases];
    [self autoHeight];
    [self showPases];
    numero_pases = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    numero_pases = 0;
}

-(void)showPases{
    //Cargamos las noticias
    sesion *s = [sesion sharedInstance];
    NSNumber *desde = [NSNumber numberWithInteger:numero_pases];
    NSNumber *hasta = [NSNumber numberWithInteger:limit_paginate];
    [[party_dao sharedInstance] getTickets:s.codigo_conexion limit:hasta page:desde y:^(NSArray *mensajes, NSError *error) {
        if (!error) {
            for (NSDictionary *JSONnoteData in mensajes) {
                [self dibujarPaseEnPosicion:JSONnoteData primeraPosicion:false];
            }
            [self autoHeight];
        } else {
            [utils controlarErrores:error];
        }
    }];
}

-(void) dibujarPaseEnPosicion:(NSDictionary *)json primeraPosicion:(bool)primeraPosicion{
    //Las UIViews de agenda
    UIView *pasesView=[[UIView alloc]initWithFrame:CGRectMake(5, numero_pases*310 + 10, 310, 360)];
    [pasesView setBackgroundColor:[UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1]];
    
    UIView *cuandoView=[[UIView alloc]initWithFrame:CGRectMake(7, 7, 302, 20)];
    [cuandoView setBackgroundColor:[UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1]];
    [pasesView addSubview:cuandoView];
    
    UILabel *nombreAgenda = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 120, 21)];
    [cuandoView addSubview:nombreAgenda];
    nombreAgenda.text=[[json objectForKey:@"party"] objectForKey:@"list_name"];
    nombreAgenda.textColor=[UIColor whiteColor];
    nombreAgenda.font = FONT_BEBAS(17.0f);
    
    UIImageView *icono_reloj = [[UIImageView alloc] initWithFrame:CGRectMake(253, 4, 11, 11)];
    [icono_reloj setImage:[UIImage imageNamed:@"5_icon_TIEMPO.png"]];
    [cuandoView addSubview:icono_reloj];
    
    UILabel *cuandoAgenda = [[UILabel alloc] initWithFrame:CGRectMake(267, 0, 43, 21)];
    [cuandoView addSubview:cuandoAgenda];
    NSString* date = [[[json objectForKey:@"party"] objectForKey:@"start_date"] substringFromIndex:11];
    cuandoAgenda.text= [date substringToIndex:5];
    cuandoAgenda.textColor=[UIColor whiteColor];
    cuandoAgenda.font = FONT_BEBAS(17.0f);
    
    UIImageView *imagen = [[UIImageView alloc] initWithFrame:CGRectMake(7, 37, 100, 100)];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[json objectForKey:@"party"] objectForKey:@"list_img"]]];
    [imagen setImage:[UIImage imageWithData:imageData]];
    [pasesView addSubview:imagen];
    
    UITextView *descripcionAgenda = [[UITextView alloc] initWithFrame:CGRectMake(108, 37, 200, 57)];
    [descripcionAgenda setBackgroundColor:[UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1]];
    [pasesView addSubview:descripcionAgenda];
    descripcionAgenda.text=[[json objectForKey:@"party"] objectForKey:@"list_description"];
    descripcionAgenda.textColor=[UIColor blackColor];
    descripcionAgenda.font = FONT_BEBAS(16.0f);
    descripcionAgenda.editable = NO;
    descripcionAgenda.scrollEnabled = NO;
    
    UIButton *buttonCondiciones = [[UIButton alloc] initWithFrame:CGRectMake(140, 112, 160, 25)];
    [pasesView addSubview:buttonCondiciones];
    [buttonCondiciones setBackgroundImage:[UIImage imageNamed:@"9_button_CONDICIONES"] forState:UIControlStateNormal];
    buttonCondiciones.accessibilityHint = [[[json objectForKey:@"party"] objectForKey:@"raffle"] objectForKey:@"conditions"];
    [buttonCondiciones addTarget:self action:@selector(mostrarCondiciones:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imagenPano = [[UIImageView alloc] initWithFrame:CGRectMake(5, 145, 300, 155)];
    NSData *imageData2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[json objectForKey:@"party"] objectForKey:@"img"]]];
    [imagenPano setImage:[UIImage imageWithData:imageData2]];
    [pasesView addSubview:imagenPano];
    
    UIButton *usarPase = [[UIButton alloc] initWithFrame:CGRectMake(61, 310, 182, 41)];
    [pasesView addSubview:usarPase];
    [usarPase setBackgroundImage:[UIImage imageNamed:@"9_button_USAR_PASE"] forState:UIControlStateNormal];
    [usarPase addTarget:self action:@selector(mostrarQR:) forControlEvents:UIControlEventTouchUpInside];
    usarPase.accessibilityHint = [json objectForKey:@"qr"];
    usarPase.accessibilityIdentifier = [[[json objectForKey:@"party"] objectForKey:@"raffle"] objectForKey:@"reward"];
    
    UIButton *buttonEvento = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 310, 114)];
    [pasesView addSubview:buttonEvento];
    [buttonEvento addTarget:self action:@selector(detallesAgenda:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *id_artist =[f numberFromString:[[json objectForKey:@"party"] objectForKey:@"id"]];
    [buttonEvento setTag:[id_artist intValue]];
    
    [_scrollView addSubview:pasesView];
    pasesView.alpha = 0.0;
    pasesView.transform =CGAffineTransformMakeScale(0,0);
    [UIView animateWithDuration:0.5 animations:^{
        pasesView.alpha = 1.0;
        pasesView.transform =CGAffineTransformMakeScale(1.0,1.0);
    }];
    numero_pases++;
    
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

-(void)mostrarQR:(UIButton*)sender
{
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:sender.accessibilityHint]];
    [_imageQR setImage:[UIImage imageWithData:imageData]];
    _modal_qr.hidden = FALSE;
    _mensajeQR.text = sender.accessibilityIdentifier;
}

- (IBAction)cerrarQR:(id)sender {
    _modal_qr.hidden = TRUE;
}

-(void)mostrarCondiciones:(UIButton*)sender
{
    _text_condiciones.text = sender.accessibilityHint;
    _modal_condiciones.hidden = FALSE;
}

- (IBAction)cerrarCondiciones:(id)sender {
    _modal_condiciones.hidden = TRUE;
}

-(void) autoHeight{
    //Auto Height Scroll
    CGFloat scrollViewHeight = 0.0f;
    
    for (UIView* view in _scrollView.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    //self.altura_scroll.constant = scrollViewHeight;
}



-(void)viewDidAppear:(BOOL)animated{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    if ([[self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2] isKindOfClass:[self class]]){
        NSMutableArray *allControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        [allControllers removeObjectAtIndex:[allControllers count] - 2];
        [self.navigationController setViewControllers:allControllers animated:NO];
    }
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
        if ([v tag]==1){
            [v removeFromSuperview];
        }
    }
    _viewBuscar.hidden = TRUE;
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
{
    if(position == FrontViewPositionLeft) {
        self.view.userInteractionEnabled = YES;
    } else {
        self.view.userInteractionEnabled = NO;
    }
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
    ultima_busqueda_pases = @"";
    if(_scrollView.userInteractionEnabled){
        _scrollView.userInteractionEnabled = FALSE;
    }
    else{
        _scrollView.userInteractionEnabled = TRUE;
    }
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
    _scrollView.userInteractionEnabled = TRUE;
}

- (IBAction)textFieldDidBeginEditing:(id)sender {
    CGRect newFrame = _viewBuscar.frame;
    newFrame.origin.y = DEVICE_SIZE.height - 310;
    _viewBuscar.frame = newFrame;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender
{
    if(![ultima_busqueda_pases isEqualToString:_textViewBuscar.text]){
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
    if(![ultima_busqueda_pases isEqualToString:_textViewBuscar.text]){
        ultima_busqueda_pases = _textViewBuscar.text;
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
                    numero_resultados_pases++;
                }
                
                [self autoWidthScrollView:scrollViewSearch];
                [self.view addSubview:scrollViewSearch];
                numero_resultados_pases = 0;
                
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


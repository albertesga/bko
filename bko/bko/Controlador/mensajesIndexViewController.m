//
//  mensajesIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "mensajesIndexViewController.h"
#import "SWRevealViewController.h"
#import "message_dao.h"
#import "sesion.h"
#import "utils.h"
#import "actualidadIndexViewController.h"
#import "agendaIndexViewController.h"
#import "sorteosIndexViewController.h"
#import "sinConexionViewController.h"
#import "articles_dao.h"
#import "constructorVistas.h"
#import "fichaViewController.h"

@interface mensajesIndexViewController ()

@property (weak, nonatomic) IBOutlet UIView *modal_escribir;
@property (weak, nonatomic) IBOutlet UIView *modal_mensaje;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll_view_modal_mensaje;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *altura_scroll;
@property (weak, nonatomic) IBOutlet UIView *view_inside_scroll;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity_indicator;
@property (weak, nonatomic) IBOutlet UITextView *mensaje_por_escribir;
@property (weak, nonatomic) IBOutlet UIButton *contestar_button;
@property (weak, nonatomic) IBOutlet UIButton *buzon_button;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@property (weak, nonatomic) IBOutlet UITextField *textViewBuscar;
@property (weak, nonatomic) IBOutlet UIView *viewBuscar;
@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation mensajesIndexViewController

int numero_mensajes = 0;
int numero_resultados_mensajes = 0;
UILabel *placeholderLabel;
NSString* ultima_busqueda_mensajes = @"";
#define DEVICE_SIZE [[[[UIApplication sharedApplication] keyWindow] rootViewController].view convertRect:[[UIScreen mainScreen] bounds] fromView:nil].size
#define limit_paginate ((int) 8)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextView *)theTextField {
    if (theTextField == self.mensaje_por_escribir) {
        [theTextField resignFirstResponder];
    }
    if (theTextField == self.textViewBuscar) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //hides keyboard when another part of layout was touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self conectado];
    
    [_viewBuscar setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.textViewBuscar.delegate=self;
    
    numero_mensajes = 0;
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 180;
    self.revealViewController.delegate = self;
    
    [self showMensajes];
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, _mensaje_por_escribir.frame.size.width - 20.0, 34.0)];
    [placeholderLabel setText:@"Escribe aquí tu mensaje"];
    // placeholderLabel is instance variable retained by view controller
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    
    // textView is UITextView object you want add placeholder text to
    [_mensaje_por_escribir addSubview:placeholderLabel];
    _mensaje_por_escribir.delegate = self;
}

- (void) textViewDidChange:(UITextView *)theTextView
{
    if(![_mensaje_por_escribir hasText]) {
        [_mensaje_por_escribir addSubview:placeholderLabel];
    } else if ([[_mensaje_por_escribir subviews] containsObject:placeholderLabel]) {
        [placeholderLabel removeFromSuperview];
    }
}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    if (![_mensaje_por_escribir hasText]) {
        [_mensaje_por_escribir addSubview:placeholderLabel];
    }
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
        if ([v tag]==50){
            [v removeFromSuperview];
        }
    }
    _viewBuscar.hidden = TRUE;
}

- (void)viewWillAppear:(BOOL)animated
{
    numero_mensajes = 0;
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

-(void)showMensajes{
    //Cargamos las noticias
    sesion *s = [sesion sharedInstance];
    [_activity_indicator startAnimating];
    _activity_indicator.hidden = FALSE;
    NSNumber *desde = [NSNumber numberWithInteger:numero_mensajes];
    NSNumber *hasta = [NSNumber numberWithInteger:limit_paginate];
    [[message_dao sharedInstance] getMessages:s.codigo_conexion limit:hasta page:desde y:^(NSArray *mensajes, NSError *error) {
        if (!error) {
            for (NSDictionary *JSONnoteData in mensajes) {
                [self dibujarMensajeEnPosicion:JSONnoteData primeraPosicion:false];
            }
            [_activity_indicator stopAnimating];
            _activity_indicator.hidden = TRUE;
            [self autoHeight];
        } else {
            [utils controlarErrores:error];
        }
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView==_scrollView){
        [self showMensajes];
    }
}

-(void) dibujarMensajeEnPosicion:(NSDictionary *)json primeraPosicion:(bool)primeraPosicion{
    //Las UIViews de cada
    UIView *contenedorView=[[UIView alloc]initWithFrame:CGRectMake(15, numero_mensajes*100+10, 290, 90)];
    numero_mensajes++;
    [contenedorView setBackgroundColor:[UIColor whiteColor]];
    [_view_inside_scroll addSubview:contenedorView];
    
    UIButton *buttonMensaje = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 290, 90)];
    [contenedorView addSubview:buttonMensaje];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *id_mensajes =[f numberFromString:[json objectForKey:@"id"]];
    [buttonMensaje setTag:[id_mensajes intValue]];
    
    [buttonMensaje addTarget:self action:@selector(verMensaje:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *tituloMensaje = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 153, 21)];
    [contenedorView addSubview:tituloMensaje];
    tituloMensaje.text=[json valueForKey:@"from"];
    tituloMensaje.textColor=[UIColor colorWithRed:0.0/255.0f green:155.0/255.0f blue:124.0/255.0f alpha:1];
    tituloMensaje.font = FONT_BEBAS(18.0f);
    tituloMensaje.textAlignment=NSTextAlignmentLeft;
    
    UILabel *fechaMensaje = [[UILabel alloc] initWithFrame:CGRectMake(180, 8, 99, 21)];
    [contenedorView addSubview:fechaMensaje];
    fechaMensaje.text=[utils fechaConFormatoMensaje:[json valueForKey:@"date"]];
    fechaMensaje.textColor=[UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1];
    fechaMensaje.font = FONT_BEBAS(18.0f);
    fechaMensaje.textAlignment=NSTextAlignmentRight;
    
    UITextView *mensaje = [[UITextView alloc] initWithFrame:CGRectMake(10, 26, 275, 60)];
    [contenedorView addSubview:mensaje];
    [mensaje setBackgroundColor:[UIColor whiteColor]];
    mensaje.text=[json valueForKey:@"text"];
    mensaje.textColor=[UIColor blackColor];
    mensaje.font = FONT_BEBAS(14.0f);
    mensaje.textAlignment=NSTextAlignmentLeft;
    mensaje.userInteractionEnabled = FALSE;

    contenedorView.alpha = 0.0;
    contenedorView.transform =CGAffineTransformMakeScale(0,0);
    [UIView animateWithDuration:0.8 animations:^{
        contenedorView.alpha = 1.0;
        contenedorView.transform =CGAffineTransformMakeScale(1.0,1.0);
    }];
    
}

-(void)verMensaje:(UIButton*)sender {
    _modal_mensaje.hidden=false;
    _modal_escribir.hidden=true;
    sesion *s = [sesion sharedInstance];
    
    for (UIView* v in _scroll_view_modal_mensaje.subviews){
        [v removeFromSuperview];
    }
    
    NSNumber* id_a = [[NSNumber alloc] initWithInt:sender.tag];
    [[message_dao sharedInstance] getMessage:s.codigo_conexion item_id:id_a y:^(NSArray *mensajes, NSError *error) {
        if (!error) {
            [[message_dao sharedInstance] getUnreadMessagesCount:s.codigo_conexion y:^(NSArray *countMessages, NSError *error) {
                if (!error) {
                    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                    
                    NSDictionary* c = [countMessages objectAtIndex:0];
                    s.messages_unread = [c objectForKey:@"count"];
                }
            }];
            for (NSDictionary *JSONnoteData in [[[mensajes objectAtIndex:0] objectForKey:@"message_thread"] objectForKey:@"messages"]) {
                CGFloat scrollViewHeight = 0.0f;
                CGFloat scrollViewWidth = 0.0f;
                for (UIView* view in _scroll_view_modal_mensaje.subviews)
                {
                    scrollViewHeight += view.frame.size.height + 10;
                }
                if([[JSONnoteData objectForKey:@"from"] isEqualToString:@"TU"]){
                    scrollViewWidth = 10;
                }
                else{
                    scrollViewWidth = 50;
                }
                UIView *contenedorView=[[UIView alloc]initWithFrame:CGRectMake(scrollViewWidth, scrollViewHeight+10, 200, 200)];
                [contenedorView setBackgroundColor:[UIColor whiteColor]];
                [_scroll_view_modal_mensaje addSubview:contenedorView];
                
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber *id_mensajes =[f numberFromString: [[[mensajes objectAtIndex:0] objectForKey:@"message_thread"] objectForKey:@"id"]];
                [_contestar_button setTag:[id_mensajes intValue]];
                
                UILabel *fechaMensaje = [[UILabel alloc] initWithFrame:CGRectMake(125, 10, 60, 21)];
                [contenedorView addSubview:fechaMensaje];
                fechaMensaje.text=[utils fechaConFormatoMensaje:[JSONnoteData valueForKey:@"date"]];
                fechaMensaje.textColor=[UIColor colorWithRed:119.0/255.0f green:119.0/255.0f blue:119.0/255.0f alpha:1];
                fechaMensaje.font = FONT_BEBAS(15.0f);
                fechaMensaje.textAlignment=NSTextAlignmentRight;
                
                UILabel *quien = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 140, 21)];
                [contenedorView addSubview:quien];
                quien.text=[JSONnoteData valueForKey:@"from"];
                quien.textColor=[UIColor colorWithRed:0.0/255.0f green:155.0/255.0f blue:124.0/255.0f alpha:1];
                quien.font = FONT_BEBAS(18.0f);
                quien.textAlignment=NSTextAlignmentLeft;
                
                UITextView *mensaje = [[UITextView alloc] initWithFrame:CGRectMake(10, 36, 200, 60)];
                [contenedorView addSubview:mensaje];
                [mensaje setBackgroundColor:[UIColor whiteColor]];
                mensaje.text=[JSONnoteData valueForKey:@"text"];
                mensaje.textColor=[UIColor blackColor];
                mensaje.font = FONT_BEBAS(14.0f);
                mensaje.textAlignment=NSTextAlignmentLeft;
                mensaje.userInteractionEnabled = NO;
                [mensaje sizeToFit];
                scrollViewHeight = 0.0f;
                for (UIView* view in contenedorView.subviews)
                {
                    scrollViewHeight += view.frame.size.height;
                }

                CGRect frameTV = contenedorView.frame;
                frameTV.size.height = scrollViewHeight;
                contenedorView.frame = frameTV;
                
                scrollViewHeight = 0.0f;
                for (UIView* view in _scroll_view_modal_mensaje.subviews)
                {
                    scrollViewHeight += view.frame.size.height;
                }
                CGRect newFrame = _scroll_view_modal_mensaje.frame;
                [_scroll_view_modal_mensaje setContentSize:(CGSizeMake(newFrame.size.width, scrollViewHeight))];
                
            }
        } else {
            [utils controlarErrores:error];
        }
    }];
    
}

- (IBAction)contestar:(id)sender {
    _modal_escribir.hidden = false;
    [_mensaje_por_escribir becomeFirstResponder];
}

- (IBAction)enviar_contestacion:(id)sender {
    sesion *s = [sesion sharedInstance];
    NSNumber* id_m = [[NSNumber alloc] initWithInt:_contestar_button.tag];
    [self.view endEditing:YES];
    [[message_dao sharedInstance] answerMessageThread:s.codigo_conexion item_id:id_m message:_mensaje_por_escribir.text y:^(NSArray *mensajes, NSError *error) {
     if (!error) {
         UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
         mensajesIndexViewController *mensajes =
         [storyboard instantiateViewControllerWithIdentifier:@"mensajesIndexViewController"];
         [self.navigationController pushViewController:mensajes animated:true];
     } else {
           [utils controlarErrores:error];
     }
     }];
}

-(void) autoHeight{
    //Auto Height Scroll
    CGFloat scrollViewHeight = 0.0f;
    
    for (UIView* view in _view_inside_scroll.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    self.altura_scroll.constant = scrollViewHeight;
}


- (IBAction)salir_escribir:(id)sender {
    _modal_escribir.hidden = true;
    [self.view endEditing:YES];
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)buzon:(id)sender {
    _modal_escribir.hidden = true;
    _modal_mensaje.hidden = true;
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
    ultima_busqueda_mensajes = @"";
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


/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //hides keyboard when another part of layout was touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
    for (UIView* v in [self.view subviews]){
        if ([v tag]==1){
            [v removeFromSuperview];
 
        }
    }
 _viewBuscar.hidden = TRUE;
    _scrollView.userInteractionEnabled = TRUE;
}*/

- (IBAction)textFieldDidBeginEditing:(id)sender {
    CGRect newFrame = _viewBuscar.frame;
    newFrame.origin.y = DEVICE_SIZE.height - 310;
    _viewBuscar.frame = newFrame;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender
{
    if(![ultima_busqueda_mensajes isEqualToString:_textViewBuscar.text]){
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
    if(![ultima_busqueda_mensajes isEqualToString:_textViewBuscar.text]){
        ultima_busqueda_mensajes = _textViewBuscar.text;
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
                    numero_resultados_mensajes++;
                }
                
                [self autoWidthScrollView:scrollViewSearch];
                [self.view addSubview:scrollViewSearch];
                numero_resultados_mensajes = 0;
                
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


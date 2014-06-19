//
//  actualidadIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 21/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "actualidadIndexViewController.h"
#import "agendaIndexViewController.h"
#import "sorteosIndexViewController.h"
#import "SWRevealViewController.h"
#import "articles_dao.h"
#import "actualidadDetalleViewController.h"
#import "sesion.h"
#import "fichaViewController.h"
#import "utils.h"
#import "sinConexionViewController.h"
#import "constructorVistas.h"

@interface actualidadIndexViewController ()
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity_indicator;
@property (weak, nonatomic) IBOutlet UIImageView *image_barra;
@property (weak, nonatomic) IBOutlet UIButton *buscar_button;
@property (weak, nonatomic) IBOutlet UIView *viewBuscar;
@property (weak, nonatomic) IBOutlet UITextField *textViewBuscar;
@property (strong, nonatomic) IBOutlet UIView *viewGeneral;
@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation actualidadIndexViewController

NSLayoutConstraint *constrainBAux;
int numero_articulos = 0;
int numero_resultados = 0;
NSString* ultima_busqueda = @"";
bool didLoadDone = false;
#define limit_paginate ((int) 50)
#define DEVICE_SIZE [[[[UIApplication sharedApplication] keyWindow] rootViewController].view convertRect:[[UIScreen mainScreen] bounds] fromView:nil].size

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
    didLoadDone = true;
    [super viewDidLoad];
    [self conectado];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationController.navigationBar.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    
    numero_articulos = 0;
    numero_resultados = 0;
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    //Menu Lateral
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 180;
    self.revealViewController.delegate = self;
    
    self.scrollView.delegate = self;
    [_viewBuscar setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.textViewBuscar.delegate=self;
    
    [self showArticulos];
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

-(void)resetView
{
    if(!didLoadDone){
        self.view=nil;
        [self viewDidLoad];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self resetView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -30) {
        scrollView.contentOffset = CGPointMake(0, -30);
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
{
    if(position == FrontViewPositionLeft) {
        self.view.userInteractionEnabled = YES;
    } else {
        self.view.userInteractionEnabled = NO;
    }
}

-(void)showArticulos{
    //Cargamos las noticias
    sesion *s = [sesion sharedInstance];
    NSNumber *desde = [NSNumber numberWithInteger:numero_articulos];
    NSNumber *hasta = [NSNumber numberWithInteger:limit_paginate];
    [_activity_indicator startAnimating];
    _activity_indicator.hidden = FALSE;
    [[articles_dao sharedInstance] getArticlesOnCompletion:s.codigo_conexion limit:hasta page:desde y:^(NSArray *articles, NSError *error) {
        if (!error) {
            for (NSDictionary *JSONnoteData in articles) {
                [self dibujarArticuloEnPosicion:JSONnoteData];
            }
            [_activity_indicator stopAnimating];
            _activity_indicator.hidden = TRUE;
            [self autoHeight];
        } else {
            // Error processing
            [utils controlarErrores:error];
        }
    }];
}

-(void) autoHeight{
    //Auto Height Scroll
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in _scrollView.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    scrollViewHeight = scrollViewHeight/2;
    if([_scrollView.subviews count]%2 != 0){
        
        UIView* aux = (UIView*)_scrollView.subviews.lastObject;
        scrollViewHeight = scrollViewHeight +aux.frame.size.height;
    }
    [_scrollView setContentSize:(CGSizeMake(320, scrollViewHeight))];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_activity_indicator startAnimating];
    _activity_indicator.hidden = FALSE;
    sesion *s = [sesion sharedInstance];
    NSNumber *desde = [NSNumber numberWithInteger:numero_articulos];
    NSNumber *hasta = [NSNumber numberWithInteger:limit_paginate];
    NSLog(@"DESDE %@",desde);
    NSLog(@"HASTA %@",hasta);
    [[articles_dao sharedInstance] getArticlesOnCompletion:s.codigo_conexion limit:hasta page:desde y:^(NSArray *articles, NSError *error) {
        if (!error) {
            //desde = [NSNumber numberWithInt:([desde integerValue] + [articles count])];
            for (NSDictionary *JSONnoteData in articles) {
                [self dibujarArticuloEnPosicion:JSONnoteData];
            }
            [_activity_indicator stopAnimating];
            _activity_indicator.hidden = TRUE;
            [self autoHeight];
        } else {
            // Error processing
            [utils controlarErrores:error];
        }
    }];
}

-(void) dibujarArticuloEnPosicion:(NSDictionary *)json{
    int fila = (numero_articulos/2);
    int columna = numero_articulos%2;
    int y = 159*fila;
    int x = 0;
    if(columna == 1){
        x = x + 161;
    }
    numero_articulos++;
    UIView *articuloView=[[UIView alloc]initWithFrame:CGRectMake(x, y, 159, 159)];
    [articuloView setBackgroundColor:[UIColor clearColor]];
    [_scrollView addSubview:articuloView];
    
    UIButton *buttonActualidad = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 159, 159)];
    
    [utils downloadImageWithURL:[NSURL URLWithString:[json valueForKey:@"list_img"]] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            [buttonActualidad setBackgroundImage:image forState:UIControlStateNormal];
        }
    }];
    [articuloView addSubview:buttonActualidad];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *id_artist =[f numberFromString:[json objectForKey:@"id"]];
    [buttonActualidad setTag:[id_artist intValue]];
    
    [buttonActualidad addTarget:self action:@selector(detallesActualidad:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 159, 159)];
    [articuloView addSubview:fondo_box];
    [articuloView sendSubviewToBack:fondo_box];
    
    UIImageView *imagen_fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(0, 133, 159, 26)];
    [imagen_fondo_box setImage:[UIImage imageNamed:@"FONDO_IMAGEN.png"]];
    [articuloView addSubview:imagen_fondo_box];
    
    UILabel *tituloActualidad = [[UILabel alloc] initWithFrame:CGRectMake(0, 135, 159, 21)];
    [articuloView addSubview:tituloActualidad];
    tituloActualidad.text=[json valueForKey:@"list_title"];
    tituloActualidad.textColor=[UIColor whiteColor];
    tituloActualidad.font = FONT_BEBAS(16.0f);
    tituloActualidad.textAlignment=NSTextAlignmentCenter;
    
    articuloView.alpha = 0.0;
    articuloView.transform =CGAffineTransformMakeScale(0,0);
    [UIView animateWithDuration:0.8 animations:^{
        articuloView.alpha = 1.0;
        articuloView.transform =CGAffineTransformMakeScale(1.0,1.0);
    }];
    
}

-(void)detallesActualidad:(UIButton*)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    actualidadDetalleViewController *actualidadController =
    [storyboard instantiateViewControllerWithIdentifier:@"actualidadDetalleViewController"];
    NSInteger id_articulo = sender.tag;
    actualidadController.id_articulo = id_articulo;
    [self.navigationController pushViewController:actualidadController animated:NO ];
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
        [self.view bringSubviewToFront:_image_barra];
        [self.view bringSubviewToFront:self.menu_button];
        [self.view bringSubviewToFront:_buscar_button];
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

- (IBAction)buscar:(id)sender {
    _textViewBuscar.text = @"";
    ultima_busqueda = @"";
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
    //_viewBuscar.hidden = FALSE;
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
    if(![ultima_busqueda isEqualToString:_textViewBuscar.text]){
        [self buscar];
        CGRect newFrame = _viewBuscar.frame;
        newFrame.origin.y = DEVICE_SIZE.height - 265;
        newFrame.size.height = 180;
        _viewBuscar.frame = newFrame;
        [self.view bringSubviewToFront:_activity_indicator];
    }
}

- (void) buscar
{
    [_activity_indicator startAnimating];
    _activity_indicator.hidden = FALSE;
    sesion *s = [sesion sharedInstance];
    if(![ultima_busqueda isEqualToString:_textViewBuscar.text]){
        ultima_busqueda = _textViewBuscar.text;
        [[articles_dao sharedInstance] search:s.codigo_conexion q:_textViewBuscar.text limit:@5 page:@0 y:^(NSArray *articles, NSError *error) {
            if (!error) {
                UIScrollView* scrollViewSearch = [[UIScrollView alloc] initWithFrame:CGRectMake(0, DEVICE_SIZE.height - 54 - 160, 320, 130)];
                scrollViewSearch.tag = 50;
                [scrollViewSearch setBackgroundColor: [UIColor colorWithRed:37.0/255.0f green:37.0/255.0f blue:37.0/255.0f alpha:1]];
                int i = 0;
                NSValue *irArtistas = [NSValue valueWithPointer:@selector(verArtista:)];
                NSValue *irSitio = [NSValue valueWithPointer:@selector(verSitio:)];
                NSValue *irSello = [NSValue valueWithPointer:@selector(verSello:)];
                for (NSDictionary *JSONnoteData in articles) {
                    [constructorVistas dibujarResultadoEnPosicion:JSONnoteData en:scrollViewSearch posicion:i selectorArtista:irArtistas selectorSitio:irSitio selectorSello:irSello controllerBase:self];
                    i++;
                    numero_resultados++;
                }
                [_activity_indicator stopAnimating];
                _activity_indicator.hidden = TRUE;
                
                [self autoWidthScrollView:scrollViewSearch];
                [self.view addSubview:scrollViewSearch];
                numero_resultados = 0;
                
            } else {
                [utils controlarErrores:error];
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


-(NSString *) stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
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

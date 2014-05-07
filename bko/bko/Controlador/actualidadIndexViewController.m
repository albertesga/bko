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

@interface actualidadIndexViewController ()
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity_indicator;
@property (weak, nonatomic) IBOutlet UIImageView *image_barra;
@property (weak, nonatomic) IBOutlet UIButton *buscar_button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;
@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation actualidadIndexViewController

int numero_articulos = 0;
#define limit_paginate ((int) 50)

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
    
    [self.navigationItem setHidesBackButton:YES];
    
    numero_articulos = 0;
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    //Menu Lateral
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 118;
    
    self.scrollView.delegate = self;
    [self showArticulos];
}

- (void)viewWillAppear:(BOOL)animated
{
    numero_articulos = 0;
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
        }
    }];
}

-(void) dibujarArticuloEnPosicion:(NSDictionary *)json{
    int fila = (numero_articulos/2);
    int columna = numero_articulos%2;
    int y = 157*fila + 3;
    int x = 3;
    if(columna == 1){
        x = x + 160;
    }
    numero_articulos++;
    UIView *articuloView=[[UIView alloc]initWithFrame:CGRectMake(x, y, 154, 154)];
    [articuloView setBackgroundColor:[UIColor clearColor]];
    [_scrollView addSubview:articuloView];
    
    UIButton *buttonActualidad = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, 146, 146)];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[json valueForKey:@"list_img"]]];
    [buttonActualidad setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
    [articuloView addSubview:buttonActualidad];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *id_artist =[f numberFromString:[json objectForKey:@"id"]];
    [buttonActualidad setTag:[id_artist intValue]];
    
    [buttonActualidad addTarget:self action:@selector(detallesActualidad:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 154, 154)];
    [fondo_box setImage:[UIImage imageNamed:@"IMATGE.png"]];
    [articuloView addSubview:fondo_box];
    [articuloView sendSubviewToBack:fondo_box];
    
    UIImageView *imagen_fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(3, 124, 148, 26)];
    [imagen_fondo_box setImage:[UIImage imageNamed:@"FONDO_IMAGEN.png"]];
    [articuloView addSubview:imagen_fondo_box];
    
    UILabel *tituloActualidad = [[UILabel alloc] initWithFrame:CGRectMake(5, 127, 149, 21)];
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
    [self.navigationController pushViewController:actualidadController animated:YES ];
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

//
//  descubrirIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "descubrirIndexViewController.h"
#import "SWRevealViewController.h"
#import "sesion.h"
#import "articles_dao.h"
#import "fichaViewController.h"
#import "register_dao.h"
#import "actualidadIndexViewController.h"
#import "agendaIndexViewController.h"
#import "sorteosIndexViewController.h"
#import "sinConexionViewController.h"
#import "utils.h"
#import "constructorVistas.h"
#import "fichaViewController.h"

@interface descubrirIndexViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *view_inside_scrollview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *altura_scroll;
@property (weak, nonatomic) IBOutlet UIImageView *banner_sitios;
@property (weak, nonatomic) IBOutlet UIImageView *banner_artistas;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@property (weak, nonatomic) IBOutlet UITextField *textViewBuscar;
@property (weak, nonatomic) IBOutlet UIView *viewBuscar;

@end

@implementation descubrirIndexViewController

int numero_art = 1;
int numero_sit = 1;
int numero_resultados_descubrir = 0;
NSString* ultima_busqueda_descubrir = @"";
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
    
    [_viewBuscar setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.textViewBuscar.delegate=self;
    
    numero_art = 1;
    numero_sit = 1;
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 180;
    self.revealViewController.delegate = self;
    
    self.altura_scroll.constant = 700;
    
    
    [self showSitios:true];
    
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

- (void) showArtistas:(bool)mas{
    //Las UIViews de cada
    sesion *s = [sesion sharedInstance];
    NSNumber *desde = [NSNumber numberWithInteger:numero_art];
    NSNumber *limit = [NSNumber numberWithInteger:1];
    [[articles_dao sharedInstance] getArtistsSuggestions:s.codigo_conexion limit:limit page:desde y:^(NSArray *articles, NSError *error) {
        if (!error) {
            if(mas){
                numero_art++;
            }
            else{
                numero_art--;
            }
            if([articles count]==0){
                [_banner_artistas setImage:[UIImage imageNamed:@"8_label_SITIOS.png"]] ;
                _banner_artistas.hidden=YES;
                for(UIView* v in _view_inside_scrollview.subviews){
                    CGRect frame = v.frame;
                    frame.origin.y = frame.origin.y-295;
                    frame.origin.x = frame.origin.x;
                    v.frame = frame;
                    if(v.tag==0){
                        [v removeFromSuperview];
                    }
                }
                UILabel *no_hay_sugerencias = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 21)];
                no_hay_sugerencias.font = FONT_BEBAS(16.0f);
                no_hay_sugerencias.text = @"NO HAY SUGERENCIAS";
                no_hay_sugerencias.textAlignment = NSTextAlignmentCenter;
                no_hay_sugerencias.textColor = [UIColor colorWithRed:163.0/255.0f green:163.0/255.0f blue:163.0/255.0f alpha:1];
                [self.view_inside_scrollview addSubview:no_hay_sugerencias];
                [self.view_inside_scrollview sendSubviewToBack:no_hay_sugerencias];
            }
            else{
                for (NSDictionary *JSONnoteData in articles) {
                    [self showArtista:JSONnoteData];
                }
            }
        } else {
            [utils controlarErrores:error];
        }
    }];
}

- (void) showSitios:(bool)mas{
    //Las UIViews de cada
    sesion *s = [sesion sharedInstance];
    NSNumber *desde = [NSNumber numberWithInteger:numero_sit];
    NSNumber *limit = [NSNumber numberWithInteger:1];
    [[articles_dao sharedInstance] getPlacesSuggestions:s.codigo_conexion limit:limit page:desde y:^(NSArray *places, NSError *error) {
        if (!error) {
            if(mas){
                numero_sit++;
            }
            else{
                numero_sit--;
            }
            if([places count]==0){
                _banner_sitios.hidden=YES;
                for(UIView* v in _view_inside_scrollview.subviews){
                    if(v.tag==50){
                        [v removeFromSuperview];
                    }
                }
            }
            else{
                for (NSDictionary *JSONnoteData in places) {
                    [self showSitio:JSONnoteData];
                }
            }
            [self showArtistas:true];
        } else {
            [utils controlarErrores:error];
        }
    }];
}

- (void) showArtista:(NSDictionary*)jsonSuggestion {
    UIView *contenedorView=[[UIView alloc]initWithFrame:CGRectMake(22, 45, 275, 257)];
    contenedorView.tag=0;
    [contenedorView setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    [_view_inside_scrollview addSubview:contenedorView];
    
    UITextView *tituloDescubrir = [[UITextView alloc] initWithFrame:CGRectMake(7, 1, 265, 70)];
    [contenedorView addSubview:tituloDescubrir];
    [tituloDescubrir setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    
    [tituloDescubrir setAttributedText:[self construirTituloSuggestion:jsonSuggestion kind:true]];
    tituloDescubrir.font = FONT_BEBAS(18.0f);
    tituloDescubrir.textAlignment=NSTextAlignmentCenter;
    tituloDescubrir.scrollEnabled = NO;
    tituloDescubrir.userInteractionEnabled = NO;
    
    UIButton *buttonImagenDescubrir = [[UIButton alloc] initWithFrame:CGRectMake(56, 55, 154, 154)];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[jsonSuggestion objectForKey:@"suggested"] objectForKey:@"img"]]];
    [buttonImagenDescubrir setBackgroundImage:[UIImage imageWithData:imageData]forState:UIControlStateNormal];
    [contenedorView addSubview:buttonImagenDescubrir];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *id_artista =[f numberFromString:[[jsonSuggestion objectForKey:@"suggested"] valueForKey:@"id" ]];
    [buttonImagenDescubrir setTag:[id_artista intValue]];
    [buttonImagenDescubrir addTarget:self action:@selector(verArtista:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imagen_fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(60, 180, 147, 26)];
    [imagen_fondo_box setImage:[UIImage imageNamed:@"FONDO_IMAGEN.png"]];
    [contenedorView addSubview:imagen_fondo_box];
    
    UILabel *tituloImagenDescubrir = [[UILabel alloc] initWithFrame:CGRectMake(60, 184, 150, 21)];
    [contenedorView addSubview:tituloImagenDescubrir];
    tituloImagenDescubrir.text=[[jsonSuggestion objectForKey:@"suggested"] objectForKey:@"name"];
    tituloImagenDescubrir.textColor=[UIColor whiteColor];
    tituloImagenDescubrir.font = FONT_BEBAS(16.0f);
    tituloImagenDescubrir.textAlignment=NSTextAlignmentCenter;
    
    UIButton *buttonSiMeGusta = [[UIButton alloc] initWithFrame:CGRectMake(20, 226, 115, 21)];
    [buttonSiMeGusta setBackgroundImage:[UIImage imageNamed:@"8_button_SI_ME_GUSTA.png"]forState:UIControlStateNormal];
    [contenedorView addSubview:buttonSiMeGusta];
    [buttonSiMeGusta setTag:[id_artista intValue]];
    [buttonSiMeGusta addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonNoMeGusta = [[UIButton alloc] initWithFrame:CGRectMake(140, 226, 115, 21)];
    [buttonNoMeGusta setBackgroundImage:[UIImage imageNamed:@"8_button_NO_ME_GUSTA.png"]forState:UIControlStateNormal];
    [contenedorView addSubview:buttonNoMeGusta];
    [buttonNoMeGusta setTag:[id_artista intValue]];
    [buttonNoMeGusta addTarget:self action:@selector(unlike:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) showSitio:(NSDictionary*)jsonSuggestion{
    UIView *contenedorView=[[UIView alloc]initWithFrame:CGRectMake(22, 340, 275, 257)];
    contenedorView.tag=1;
    [contenedorView setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    [_view_inside_scrollview addSubview:contenedorView];
    
    UITextView *tituloDescubrir = [[UITextView alloc] initWithFrame:CGRectMake(7, 1, 265, 70)];
    [contenedorView addSubview:tituloDescubrir];
    [tituloDescubrir setBackgroundColor:[UIColor colorWithRed:215.0/255.0f green:215.0/255.0f blue:215.0/255.0f alpha:1]];
    
    [tituloDescubrir setAttributedText:[self construirTituloSuggestion:jsonSuggestion kind:false]];
    tituloDescubrir.font = FONT_BEBAS(18.0f);
    tituloDescubrir.textAlignment=NSTextAlignmentCenter;
    tituloDescubrir.scrollEnabled = NO;
    
    UIButton *buttonImagenDescubrir = [[UIButton alloc] initWithFrame:CGRectMake(56, 55, 154, 154)];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[jsonSuggestion objectForKey:@"suggested"] objectForKey:@"img"]]];
    [buttonImagenDescubrir setBackgroundImage:[UIImage imageWithData:imageData]forState:UIControlStateNormal];
    [contenedorView addSubview:buttonImagenDescubrir];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *id_sitio =[f numberFromString:[[jsonSuggestion objectForKey:@"suggested"] valueForKey:@"id" ]];
    [buttonImagenDescubrir setTag:[id_sitio intValue]];
    [buttonImagenDescubrir addTarget:self action:@selector(verSitio:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imagen_fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(60, 180, 147, 26)];
    [imagen_fondo_box setImage:[UIImage imageNamed:@"FONDO_IMAGEN.png"]];
    [contenedorView addSubview:imagen_fondo_box];
    
    UILabel *tituloImagenDescubrir = [[UILabel alloc] initWithFrame:CGRectMake(60, 184, 150, 21)];
    [contenedorView addSubview:tituloImagenDescubrir];
    tituloImagenDescubrir.text=[[jsonSuggestion objectForKey:@"suggested"] objectForKey:@"name"];
    tituloImagenDescubrir.textColor=[UIColor whiteColor];
    tituloImagenDescubrir.font = FONT_BEBAS(16.0f);
    tituloImagenDescubrir.textAlignment=NSTextAlignmentCenter;
    
    UIButton *buttonSiMeGusta = [[UIButton alloc] initWithFrame:CGRectMake(20, 226, 115, 21)];
    [buttonSiMeGusta setBackgroundImage:[UIImage imageNamed:@"8_button_SI_ME_GUSTA.png"]forState:UIControlStateNormal];
    [contenedorView addSubview:buttonSiMeGusta];
    [buttonSiMeGusta setTag:[id_sitio intValue]];
    [buttonSiMeGusta addTarget:self action:@selector(likeSitio:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonNoMeGusta = [[UIButton alloc] initWithFrame:CGRectMake(140, 226, 115, 21)];
    [buttonNoMeGusta setBackgroundImage:[UIImage imageNamed:@"8_button_NO_ME_GUSTA.png"]forState:UIControlStateNormal];
    [contenedorView addSubview:buttonNoMeGusta];
    [buttonNoMeGusta setTag:[id_sitio intValue]];
    [buttonNoMeGusta addTarget:self action:@selector(unlikeSitio:) forControlEvents:UIControlEventTouchUpInside];
    
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

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)like:(UIButton*)sender {
    
    NSNumber* tipo_like = [[NSNumber alloc] initWithInt:2];
    NSNumber* tipo_artista = [[NSNumber alloc] initWithInt:0];
    NSNumber* id_a = [[NSNumber alloc] initWithInt:sender.tag];
    sesion *s = [sesion sharedInstance];
    [[register_dao sharedInstance] setLiked:s.codigo_conexion kind:tipo_artista item_id:id_a like_kind:tipo_like y:^(NSArray *like, NSError *error){
        if (!error) {
            [self showArtistas:true];
        } else {
            [utils controlarErrores:error];
        }
    }];
}

- (void)mas:(UIButton*)sender {
    [self showArtistas:true];
}

- (void)menos:(UIButton*)sender {
    [self showArtistas:false];
}

- (void)unlike:(UIButton*)sender {
    
    NSNumber* tipo_like = [[NSNumber alloc] initWithInt:2];
    NSNumber* tipo_artista = [[NSNumber alloc] initWithInt:0];
    NSNumber* id_a = [[NSNumber alloc] initWithInt:sender.tag];
    sesion *s = [sesion sharedInstance];
    [[register_dao sharedInstance] setUnliked:s.codigo_conexion kind:tipo_artista item_id:id_a like_kind:tipo_like y:^(NSArray *unlike, NSError *error){
        if (!error) {
            [self showArtistas:true];
        } else {
            [utils controlarErrores:error];
        }
    }];
}

- (void)likeSitio:(UIButton*)sender {
    
    NSNumber* tipo_like = [[NSNumber alloc] initWithInt:2];
    NSNumber* tipo_sitio = [[NSNumber alloc] initWithInt:1];
    NSNumber* id_a = [[NSNumber alloc] initWithInt:sender.tag];
    sesion *s = [sesion sharedInstance];
    [[register_dao sharedInstance] setLiked:s.codigo_conexion kind:tipo_sitio item_id:id_a like_kind:tipo_like y:^(NSArray *like, NSError *error){
        if (!error) {
            [self showSitios:true];
        } else {
            [utils controlarErrores:error];
        }
    }];
}

- (void)masSitios:(UIButton*)sender {
    [self showSitios:true];
}

- (void)menosSitios:(UIButton*)sender {
    [self showSitios:false];
}

- (void)unlikeSitio:(UIButton*)sender {
    
    NSNumber* tipo_like = [[NSNumber alloc] initWithInt:2];
    NSNumber* tipo_sitio = [[NSNumber alloc] initWithInt:1];
    NSNumber* id_a = [[NSNumber alloc] initWithInt:sender.tag];
    sesion *s = [sesion sharedInstance];
    [[register_dao sharedInstance] setUnliked:s.codigo_conexion kind:tipo_sitio item_id:id_a like_kind:tipo_like y:^(NSArray *unlike, NSError *error){
        if (!error) {
            [self showSitios:true];
        } else {
            [utils controlarErrores:error];
        }
    }];
}

-(NSMutableAttributedString*) construirTituloSuggestion:(NSDictionary*)jsonArtista kind:(bool)kind{
    NSString *returnString =@"A MUCHOS QUE LES GUSTA ";
    NSString *primer_suggest =@"";
    NSString *segundo_suggest =@"";
    if(kind){
        primer_suggest =@"artist_1";
        segundo_suggest =@"artist_2";
    }
    else{
        primer_suggest =@"place_1";
        segundo_suggest =@"place_2";
    }
    returnString = [returnString stringByAppendingString:[[jsonArtista objectForKey:primer_suggest]objectForKey:@"name"]];
    returnString = [returnString stringByAppendingString:@" Y "];
    returnString = [returnString stringByAppendingString:[[jsonArtista objectForKey:segundo_suggest]objectForKey:@"name"]];
    
    returnString = [returnString stringByAppendingString:@" TAMBIÉN LES GUSTA "];
    returnString = [returnString stringByAppendingString:[[jsonArtista objectForKey:@"suggested"]objectForKey:@"name"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:returnString];
    
    NSRange range = [returnString rangeOfString:[[jsonArtista objectForKey:primer_suggest] objectForKey:@"name"]];
    NSRange range2 = [returnString rangeOfString:[[jsonArtista objectForKey:segundo_suggest] objectForKey:@"name"]];
    NSRange range3 = [returnString rangeOfString:[[jsonArtista objectForKey:@"suggested"] objectForKey:@"name"]];
    
    
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0/255.0f green:108.0/255.0f blue:124.0/255.0f alpha:1] range:range];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0/255.0f green:108.0/255.0f blue:124.0/255.0f alpha:1] range:range2];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0/255.0f green:103.0/255.0f blue:92.0/255.0f alpha:1] range:range3];
    return string;
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
    ultima_busqueda_descubrir = @"";
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
    if(![ultima_busqueda_descubrir isEqualToString:_textViewBuscar.text]){
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
    if(![ultima_busqueda_descubrir isEqualToString:_textViewBuscar.text]){
        ultima_busqueda_descubrir = _textViewBuscar.text;
        [[articles_dao sharedInstance] search:s.codigo_conexion q:_textViewBuscar.text limit:@5 page:@0 y:^(NSArray *articles, NSError *error) {
            if (!error) {
                UIScrollView* scrollViewSearch = [[UIScrollView alloc] initWithFrame:CGRectMake(0, DEVICE_SIZE.height - 54 - 166, 320, 130)];
                scrollViewSearch.tag = 50;
                [scrollViewSearch setBackgroundColor: [UIColor colorWithRed:37.0/255.0f green:37.0/255.0f blue:37.0/255.0f alpha:1]];
                int i = 0;
                NSValue *irArtistas = [NSValue valueWithPointer:@selector(verArtista2:)];
                NSValue *irSitio = [NSValue valueWithPointer:@selector(verSitio2:)];
                NSValue *irSello = [NSValue valueWithPointer:@selector(verSello:)];
                for (NSDictionary *JSONnoteData in articles) {
                    [constructorVistas dibujarResultadoEnPosicion:JSONnoteData en:scrollViewSearch posicion:i selectorArtista:irArtistas selectorSitio:irSitio selectorSello:irSello controllerBase:self];
                    i++;
                    numero_resultados_descubrir++;
                }
                
                [self autoWidthScrollView:scrollViewSearch];
                [self.view addSubview:scrollViewSearch];
                numero_resultados_descubrir = 0;
                
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

-(void)verSitio2:(UIButton*)sender
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

-(void)verArtista2:(UIButton*)sender
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


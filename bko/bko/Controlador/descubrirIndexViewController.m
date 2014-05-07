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

@interface descubrirIndexViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *view_inside_scrollview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *altura_scroll;
@property (weak, nonatomic) IBOutlet UIImageView *banner_sitios;
@property (weak, nonatomic) IBOutlet UIImageView *banner_artistas;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;

@end

@implementation descubrirIndexViewController

int numero_art = 1;
int numero_sit = 1;

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
    
    numero_art = 1;
    numero_sit = 1;
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 118;
    
    self.altura_scroll.constant = 700;
    
    
    [self showSitios:true];
    
    
    
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
                _banner_sitios.hidden=YES;
                for(UIView* v in _view_inside_scrollview.subviews){
                    CGRect frame = v.frame;
                    frame.origin.y = frame.origin.y-295;
                    frame.origin.x = frame.origin.x;
                    v.frame = frame;
                    NSLog(@"VISTA %@", [v class]);
                    NSLog(@"X %f", frame.origin.y);
                    NSLog(@"Y %f", frame.origin.x);
                    if(v.tag==0){
                        [v removeFromSuperview];
                    }
                    /*else if(v.tag==1){
                        CGRect frame = v.frame;
                        frame.origin.y = 45;
                        v.frame = frame;
                        
                        frame = _banner_sitios.frame;
                        frame.origin.y = 15;
                        _banner_sitios.frame = frame;
                    }*/
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
            // Error processing
            NSLog(@"Error al hacer getArtistsSuggestions: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
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
                    if(v.tag==1){
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
            // Error processing
            NSLog(@"Error al hacer getPlacesSuggestions: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
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
    
    UIButton *derecha = [[UIButton alloc] initWithFrame:CGRectMake(305, 158, 6, 11)];
    [derecha setBackgroundImage:[UIImage imageNamed:@"8_icon_DERECHA.png"]forState:UIControlStateNormal];
    [_view_inside_scrollview addSubview:derecha];
    [derecha addTarget:self action:@selector(mas:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *izquierda = [[UIButton alloc] initWithFrame:CGRectMake(10, 158, 6, 11)];
    [izquierda setBackgroundImage:[UIImage imageNamed:@"8_icon_IZQUIERDA.png"]forState:UIControlStateNormal];
    [_view_inside_scrollview addSubview:izquierda];
    [izquierda addTarget:self action:@selector(menos:) forControlEvents:UIControlEventTouchUpInside];
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
    
    UIButton *derecha = [[UIButton alloc] initWithFrame:CGRectMake(305, 470, 6, 11)];
    [derecha setBackgroundImage:[UIImage imageNamed:@"8_icon_DERECHA.png"]forState:UIControlStateNormal];
    [_view_inside_scrollview addSubview:derecha];
    [derecha addTarget:self action:@selector(masSitios:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *izquierda = [[UIButton alloc] initWithFrame:CGRectMake(10, 470, 6, 11)];
    [izquierda setBackgroundImage:[UIImage imageNamed:@"8_icon_IZQUIERDA.png"]forState:UIControlStateNormal];
    [_view_inside_scrollview addSubview:izquierda];
    [izquierda addTarget:self action:@selector(menosSitios:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)verArtista:(UIButton*)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    fichaViewController *fichaController =
    [storyboard instantiateViewControllerWithIdentifier:@"fichaViewController"];
    NSInteger id_art = sender.tag;
    fichaController.id_card = id_art;
    fichaController.kind = 0;
    [self presentViewController:fichaController animated:YES completion:nil];
}

-(void)verSitio:(UIButton*)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    fichaViewController *fichaController =
    [storyboard instantiateViewControllerWithIdentifier:@"fichaViewController"];
    NSInteger id_art = sender.tag;
    fichaController.id_card = id_art;
    fichaController.kind = 1;
    [self presentViewController:fichaController animated:YES completion:nil];
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
            // Error hacer el like
            NSLog(@"Error al like: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
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
            // Error hacer el like
            NSLog(@"Error al like: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
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
            // Error hacer el like
            NSLog(@"Error al like: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
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
            // Error hacer el like
            NSLog(@"Error al like: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
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
    NSLog(@"PRIMER SUGGEST %@", jsonArtista);
    NSLog(@"PRIMER SUGGEST %@", primer_suggest);
    NSLog(@"PRIMER SUGGEST %@", [[jsonArtista objectForKey:primer_suggest]objectForKey:@"name"]);
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


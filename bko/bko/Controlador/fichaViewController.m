//
//  fichaViewController.m
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "fichaViewController.h"
#import "sesion.h"
#import "SWRevealViewController.h"
#import "articles_dao.h"
#import "utils.h"
#import "register_dao.h"
#import "constructorVistas.h"
#import "actualidadDetalleViewController.h"
#import "actualidadIndexViewController.h"
#import "agendaIndexViewController.h"
#import "sorteosIndexViewController.h"

@interface fichaViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titulo_barra_superior;
@property (weak, nonatomic) IBOutlet UILabel *nombre_ficha;
@property (weak, nonatomic) IBOutlet UILabel *tipo_ficha_label;
@property (weak, nonatomic) IBOutlet UILabel *info_label;
@property (weak, nonatomic) IBOutlet UIButton *anadir_button;
@property (weak, nonatomic) IBOutlet UIButton *quitar_button;
@property (weak, nonatomic) IBOutlet UIView *ya_no_te_gusta_modal;
@property (weak, nonatomic) IBOutlet UIView *anadido_modal;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll_view;
@property (weak, nonatomic) IBOutlet UIImageView *imagen_card;
@property (weak, nonatomic) IBOutlet UITextView *descripcion;
@property (weak, nonatomic) IBOutlet UIView *view_scroll;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *altura_scroll;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;

@end

@implementation fichaViewController

@synthesize id_card;
@synthesize kind;
NSString *web_link;
NSString *facebook_link;
NSString *twitter_link;
NSString *instagram_link;
NSString *souncloud_link;
NSNumber *kind_c;
NSNumber *id_c;

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
    
    kind_c = [[NSNumber alloc] initWithInt:kind];
    id_c = [[NSNumber alloc] initWithInt:id_card];
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    _titulo_barra_superior.font = FONT_BEBAS(22.0f);
    _nombre_ficha.font = FONT_BEBAS(27.0f);
    _tipo_ficha_label.font = FONT_BEBAS(15.0f);
    _info_label.font = FONT_BEBAS(15.0f);
    
    //Menu Lateral
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 118;
    

        sesion *s = [sesion sharedInstance];
        [[articles_dao sharedInstance] getCard:s.codigo_conexion kind:kind_c item_id:id_c y:^(NSArray *card, NSError *error) {
            if (!error) {
                NSDictionary* card_json = [card objectAtIndex:0];
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[card_json valueForKey:@"img"]]];
                [_imagen_card setImage:[UIImage imageWithData:imageData]];
                _descripcion.text = [[card_json objectForKey:@"content"] objectForKey:@"content"];
                [_descripcion sizeToFit];
                [_descripcion layoutIfNeeded];
                _nombre_ficha.text = [card_json objectForKey:@"name"];
                self.navigationItem.title = [card_json objectForKey:@"name"];
                _tipo_ficha_label.text = [utils getNameKind:[card_json objectForKey:@"kind"]];
                bool seleccionado = [[card_json objectForKey:@"is_liked"] boolValue];
                if(seleccionado == true){
                    _anadir_button.hidden=true;
                    _quitar_button.hidden=false;
                }
                [self construir_contenido:card_json];
                [self colocar_iconos_redes_sociales:card_json];
            } else {
                // Error hacer al recoger Artículo
                NSLog(@"Error al recoger el card: %@", error);
                UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                   message:[error localizedDescription]
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                [theAlert show];
            }
        }];
    
}

- (IBAction)anadir_mis_gustos:(id)sender {
    
    NSNumber* dos = [[NSNumber alloc] initWithInt:2];
    sesion *s = [sesion sharedInstance];
    [[register_dao sharedInstance] setLiked:s.codigo_conexion kind:kind_c item_id:id_c like_kind:dos y:^(NSArray *artists, NSError *error){
        if (!error) {
            [self mostrar_quitar];
            [NSTimer scheduledTimerWithTimeInterval:8.0
                                             target:self
                                           selector:@selector(esconder_modals)
                                           userInfo:nil
                                            repeats:NO];
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(esconder_modals)];
            [_anadido_modal addGestureRecognizer:tapRecognizer];
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
- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)quitar_mis_gustos:(id)sender {
    
    NSNumber* dos = [[NSNumber alloc] initWithInt:2];
    sesion *s = [sesion sharedInstance];
    [[register_dao sharedInstance] setUnliked:s.codigo_conexion kind:kind_c item_id:id_c like_kind:dos y:^(NSArray *artists, NSError *error){
        
        if (!error) {
            [self mostrar_anadir];
            [NSTimer scheduledTimerWithTimeInterval:8.0
                                             target:self
                                           selector:@selector(esconder_modals)
                                           userInfo:nil
                                            repeats:NO];
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(esconder_modals)];
            [_ya_no_te_gusta_modal addGestureRecognizer:tapRecognizer];

        } else {
            // Error hacer el unlike
            NSLog(@"Error al hacer unlike: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
    }];
}

-(void)esconder_modals{
    _anadido_modal.hidden=true;
    _ya_no_te_gusta_modal.hidden=true;
}

-(void)mostrar_anadir{
    _anadir_button.hidden=false;
    _quitar_button.hidden=true;
    _ya_no_te_gusta_modal.hidden=false;
    _anadido_modal.hidden=true;
}

-(void)mostrar_quitar{
    _anadir_button.hidden=true;
    _quitar_button.hidden=false;
    _anadido_modal.hidden=false;
    _ya_no_te_gusta_modal.hidden=true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)construir_contenido:(NSDictionary*)json_content{
    //Creamos el contenido de la descripción
    NSMutableArray* parts=[utils generarContenidoDescripcion:[[json_content objectForKey:@"content"] objectForKey:@"content"]];
    int y = 484;
    for (NSString* x in parts){
        
        if([[x substringToIndex:2] isEqual:@"{{"]){
            NSString* codigo_sin_corchetes = [x substringFromIndex:2];
            codigo_sin_corchetes = [codigo_sin_corchetes substringToIndex:codigo_sin_corchetes.length -2];
            for(NSDictionary* json in [[json_content objectForKey:@"content"] objectForKey:@"content_gallery_embeds"]){
                if([[json valueForKey:@"code"] isEqualToString:codigo_sin_corchetes]){
                    if([json valueForKey:@"name"] != nil && ![[json valueForKey:@"name"] isEqualToString:@""]){
                        [_view_scroll addSubview:[constructorVistas construirTitulo:[json objectForKey:@"name"] poscion:y]];
                        y = y+30;
                    }
                    [_view_scroll addSubview:[constructorVistas construir_scroll_embeds:json posicion:y]];
                    y = y+150;
                }
            }
            
            for(NSDictionary* json in [[json_content objectForKey:@"content"] objectForKey:@"content_gallery_images"]){
                if([[json valueForKey:@"code"] isEqualToString:codigo_sin_corchetes]){
                    if([json valueForKey:@"name"] != nil && ![[json valueForKey:@"name"] isEqualToString:@""]){
                        [_view_scroll addSubview:[constructorVistas construirTitulo:[json objectForKey:@"name"] poscion:y]];
                        y = y+30;
                    }
                    [_view_scroll addSubview:[constructorVistas construir_scroll_images:json posicion:y]];
                    y = y+150;
                }
            }
        }
        else if(![x isEqualToString:@""]){
            /*UIWebView* myUIWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, y, 320, 400)];
            [myUIWebView setUserInteractionEnabled:NO];
            [myUIWebView setBackgroundColor:[UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0]];
            [myUIWebView loadHTMLString:x baseURL:nil];
            [myUIWebView sizeToFit];
             y = y + myTextView.frame.size.height;
             [_view_scroll addSubview:myTextView];*/
            UITextView *myTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, y, 320, 400)];
            [myTextView setUserInteractionEnabled:NO];
            [myTextView setBackgroundColor:[UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0]];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[x dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            UIFont *font=[UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
            NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
            paragrapStyle.alignment = NSTextAlignmentCenter;
            NSInteger stringLength=[attributedString length];
            [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, stringLength)];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrapStyle range:NSMakeRange(0, stringLength)];
            
            
            myTextView.attributedText = attributedString;
            [myTextView sizeToFit];
            y = y + myTextView.frame.size.height;
            [_view_scroll addSubview:myTextView];
        }
    }
    [self autoHeight];
    [self show_items_relacionados:json_content];
}

- (void)embeds_finales:(NSDictionary*)json_content{
    [self autoHeight];
    int y = self.altura_scroll.constant;
    for(NSDictionary* json in [[json_content objectForKey:@"content"] objectForKey:@"content_gallery_embeds"]){
        if([json valueForKey:@"name"] != nil && ![[json valueForKey:@"name"] isEqualToString:@""]){
            y = y +15;
            [_view_scroll addSubview:[constructorVistas construirTitulo:[json objectForKey:@"name"] poscion:y]];
            y = y+30;
            [_view_scroll addSubview:[constructorVistas construir_scroll_embeds:json posicion:y]];
            y = y+150;
        }
    }
    
    for(NSDictionary* json in [[json_content objectForKey:@"content"] objectForKey:@"content_gallery_images"]){
        if([json valueForKey:@"name"] != nil && ![[json valueForKey:@"name"] isEqualToString:@""]){
            y = y + 15;
            [_view_scroll addSubview:[constructorVistas construirTitulo:[json objectForKey:@"name"] poscion:y]];
            y = y + 30;
            [_view_scroll addSubview:[constructorVistas construir_scroll_images:json posicion:y]];
            y = y + 150;
        }
    }
    [self autoHeight];
}

- (void)show_items_relacionados:(NSDictionary*)json_content{
    
    sesion *s = [sesion sharedInstance];
    NSNumber* tipo_artistas = [[NSNumber alloc] initWithInt:[utils getKind:@"Artist"]];
    NSNumber* tipo_ficha = [[NSNumber alloc] initWithInt:kind];
    NSNumber* id_a = [[NSNumber alloc] initWithInt:id_card];
    [self autoHeight];
    [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_ficha item_id:id_a related_kind:tipo_artistas limit:@10 page:@1 y:^(NSArray *artistas, NSError *error) {
        if (!error) {
            if([artistas count]>0){
                [_view_scroll addSubview:[constructorVistas construirTitulo:@"Artistas Relacionados" poscion:self.altura_scroll.constant]];
                NSValue *irArtistas = [NSValue valueWithPointer:@selector(verArtista:)];
                [_view_scroll addSubview:[constructorVistas scrollLateral:artistas posicion:self.altura_scroll.constant selector:irArtistas controllerBase:self]];
                [self autoHeight];
            }
            NSNumber* tipo_sitio = [[NSNumber alloc] initWithInt:[utils getKind:@"Sitio"]];
            [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_ficha item_id:id_a related_kind:tipo_sitio limit:@10 page:@1 y:^(NSArray *sitios, NSError *error) {
                if (!error) {
                    if([sitios count]>0){
                        [_view_scroll addSubview:[constructorVistas construirTitulo:@"Sitios Relacionados" poscion:self.altura_scroll.constant]];
                        NSValue *irSitios = [NSValue valueWithPointer:@selector(verSitio:)];
                        [_view_scroll addSubview:[constructorVistas scrollLateral:sitios posicion:self.altura_scroll.constant selector:irSitios controllerBase:self]];
                        [self autoHeight];
                    }
                    NSNumber* tipo_articulos = [[NSNumber alloc] initWithInt:[utils getKind:@"Artículo"]];
                    [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_ficha item_id:id_a related_kind:tipo_articulos limit:@10 page:@1 y:^(NSArray *articulos, NSError *error) {
                        if (!error) {
                            if([articulos count]>0){
                                [_view_scroll addSubview:[constructorVistas construirTitulo:@"Artículos Relacionados" poscion:self.altura_scroll.constant]];
                                NSValue *irArticulos = [NSValue valueWithPointer:@selector(verArticulo:)];
                                [_view_scroll addSubview:[constructorVistas scrollLateral:articulos posicion:self.altura_scroll.constant selector:irArticulos controllerBase:self]];
                                [self autoHeight];
                            }
                            NSNumber* tipo_sello = [[NSNumber alloc] initWithInt:[utils getKind:@"Sello"]];
                            [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_ficha item_id:id_a related_kind:tipo_sello limit:@10 page:@1 y:^(NSArray *sellos, NSError *error) {
                                if (!error) {
                                    if([sellos count]>0){
                                        [_view_scroll addSubview:[constructorVistas construirTitulo:@"Sellos Relacionados" poscion:self.altura_scroll.constant]];
                                        NSValue *irSellos = [NSValue valueWithPointer:@selector(verSello:)];
                                        [_view_scroll addSubview:[constructorVistas scrollLateralItemsPeques:articulos posicion:self.altura_scroll.constant selector:irSellos controllerBase:self]];
                                        [self autoHeight];
                                    }
                                    NSNumber* tipo_entrevista = [[NSNumber alloc] initWithInt:[utils getKind:@"Entrevista"]];
                                    [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_ficha item_id:id_a related_kind:tipo_entrevista limit:@10 page:@1 y:^(NSArray *entrevistas, NSError *error) {
                                        if (!error) {
                                            if([entrevistas count]>0){
                                                [_view_scroll addSubview:[constructorVistas construirTitulo:@"Entrevistas Relacionadas" poscion:self.altura_scroll.constant]];
                                                NSValue *irArticulos = [NSValue valueWithPointer:@selector(verArticulo:)];
                                                [_view_scroll addSubview:[constructorVistas scrollLateral:articulos posicion:self.altura_scroll.constant selector:irArticulos controllerBase:self]];
                                                [self autoHeight];
                                            }
                                            [self embeds_finales:json_content];
                                        } else {
                                            // Error hacer al recoger los items relacionados
                                            NSLog(@"Error al recoger el card: %@", error);
                                            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                               message:[error localizedDescription]
                                                                                              delegate:self
                                                                                     cancelButtonTitle:@"OK"
                                                                                     otherButtonTitles:nil];
                                            [theAlert show];
                                        }
                                    }];
                                } else {
                                    // Error hacer al recoger los items relacionados
                                    NSLog(@"Error al recoger el card: %@", error);
                                    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                       message:[error localizedDescription]
                                                                                      delegate:self
                                                                             cancelButtonTitle:@"OK"
                                                                             otherButtonTitles:nil];
                                    [theAlert show];
                                }
                            }];
                        } else {
                            // Error hacer al recoger los items relacionados
                            NSLog(@"Error al recoger el card: %@", error);
                            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                               message:[error localizedDescription]
                                                                              delegate:self
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil];
                            [theAlert show];
                        }
                    }];
                } else {
                    // Error hacer al recoger los items relacionados
                    NSLog(@"Error al recoger el card: %@", error);
                    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                       message:[error localizedDescription]
                                                                      delegate:self
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                    [theAlert show];
                }
            }];
            
        } else {
            // Error hacer al recoger los items relacionados
            NSLog(@"Error al recoger el card: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
    }];
    
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

-(void)verArticulo:(UIButton*)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    actualidadDetalleViewController *actualidadDetalle =
    [storyboard instantiateViewControllerWithIdentifier:@"actualidadDetalleViewController"];
    NSInteger id_art = sender.tag;
    actualidadDetalle.id_articulo = id_art;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:actualidadDetalle animated:YES ];
    
}

-(void) autoHeight{
    //Auto Height Scroll
    CGFloat scrollViewHeight = 0.0f;
    
    for (UIView* view in _view_scroll.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    self.altura_scroll.constant = scrollViewHeight - 79 - 79 - 21 - 21 + 190;
}

- (void)colocar_iconos_redes_sociales:(NSDictionary*)card_json{
    int num_iconos = 0;
    if([card_json valueForKey:@"web"]!=nil && ![[card_json valueForKey:@"web"] isEqualToString:@""]){
        num_iconos++;
        web_link = [card_json valueForKey:@"web"];
    }
    if([card_json valueForKey:@"facebook"]!=nil && ![[card_json valueForKey:@"facebook"] isEqualToString:@""]){
        num_iconos++;
        facebook_link = [card_json valueForKey:@"facebook"];
    }
    if([card_json valueForKey:@"twitter"]!=nil && ![[card_json valueForKey:@"twitter"] isEqualToString:@""]){
        num_iconos++;
        twitter_link = [card_json valueForKey:@"twitter"];
    }
    if([card_json valueForKey:@"instagram"]!=nil && ![[card_json valueForKey:@"instagram"] isEqualToString:@""]){
        num_iconos++;
        instagram_link = [card_json valueForKey:@"instagram"];
    }
    if([card_json valueForKey:@"soundcloud"]!=nil && ![[card_json valueForKey:@"soundcloud"] isEqualToString:@""]){
        num_iconos++;
        souncloud_link = [card_json valueForKey:@"soundcloud"];
    }
    int incremento = 240;
    if(num_iconos!=1){
        incremento = 240/(num_iconos-1) ;
    }
    int posicion_inicial = 40;
    if(num_iconos==1){
        posicion_inicial = 160;
    }
    if (num_iconos==2){
        posicion_inicial = 110;
        incremento = 100;
    }
    if([card_json valueForKey:@"web"]!=nil && ![[card_json valueForKey:@"web"] isEqualToString:@""]){
        UIButton *buttonWeb = [[UIButton alloc] initWithFrame:CGRectMake(posicion_inicial - 17, 412, 34, 34)];
        [buttonWeb setBackgroundImage:[UIImage imageNamed:@"12_button_WWW.png"] forState:UIControlStateNormal];
        [buttonWeb addTarget:self action:@selector(web:) forControlEvents:UIControlEventTouchUpInside];
        [_scroll_view addSubview:buttonWeb];
        posicion_inicial= posicion_inicial+incremento;
    }
    if([card_json valueForKey:@"facebook"]!=nil && ![[card_json valueForKey:@"facebook"] isEqualToString:@""]){
        UIButton *buttonWeb = [[UIButton alloc] initWithFrame:CGRectMake(posicion_inicial - 17, 412, 34, 34)];
        [buttonWeb setBackgroundImage:[UIImage imageNamed:@"12_button_FB.png"] forState:UIControlStateNormal];
        [buttonWeb addTarget:self action:@selector(facebook:) forControlEvents:UIControlEventTouchUpInside];
        [_scroll_view addSubview:buttonWeb];
        posicion_inicial= posicion_inicial+incremento;
    }
    if([card_json valueForKey:@"twitter"]!=nil && ![[card_json valueForKey:@"twitter"] isEqualToString:@""]){
        UIButton *buttonWeb = [[UIButton alloc] initWithFrame:CGRectMake(posicion_inicial - 17, 412, 34, 34)];
        [buttonWeb setBackgroundImage:[UIImage imageNamed:@"12_button_TWITTER.png"] forState:UIControlStateNormal];
        [buttonWeb addTarget:self action:@selector(twitter:) forControlEvents:UIControlEventTouchUpInside];
        [_scroll_view addSubview:buttonWeb];
        posicion_inicial= posicion_inicial+incremento;
    }
    if([card_json valueForKey:@"instagram"]!=nil && ![[card_json valueForKey:@"instagram"] isEqualToString:@""]){
        UIButton *buttonWeb = [[UIButton alloc] initWithFrame:CGRectMake(posicion_inicial - 17, 412, 34, 34)];
        [buttonWeb addTarget:self action:@selector(instagram:) forControlEvents:UIControlEventTouchUpInside];
        [buttonWeb setBackgroundImage:[UIImage imageNamed:@"12_button_INSTAGRAM.png"] forState:UIControlStateNormal];
        [_scroll_view addSubview:buttonWeb];
        posicion_inicial= posicion_inicial+incremento;
    }
    if([card_json valueForKey:@"soundcloud"]!=nil && ![[card_json valueForKey:@"soundcloud"] isEqualToString:@""]){
        UIButton *buttonWeb = [[UIButton alloc] initWithFrame:CGRectMake(posicion_inicial - 17, 412, 34, 34)];
        [buttonWeb addTarget:self action:@selector(soundcloud:) forControlEvents:UIControlEventTouchUpInside];
        [buttonWeb setBackgroundImage:[UIImage imageNamed:@"12_button_SOUNDCLOUD.png"] forState:UIControlStateNormal];
        [_scroll_view addSubview:buttonWeb];
        posicion_inicial= posicion_inicial+incremento;
    }
}

- (IBAction)web:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:web_link]];
}
- (IBAction)facebook:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facebook_link]];
}
- (IBAction)twitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitter_link]];
}
- (IBAction)instagram:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagram_link]];
}
- (IBAction)soundcloud:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:souncloud_link]];
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


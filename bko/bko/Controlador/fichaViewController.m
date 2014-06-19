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
#import "sinConexionViewController.h"



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
@property (weak, nonatomic) IBOutlet UITextField *textViewBuscar;
@property (weak, nonatomic) IBOutlet UIView *viewBuscar;

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
int numero_resultados_ficha = 0;
NSString* ultima_busqueda_ficha = @"";
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
    
    kind_c = [[NSNumber alloc] initWithInt:kind];
    id_c = [[NSNumber alloc] initWithInt:id_card];
    
    [_viewBuscar setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.textViewBuscar.delegate=self;
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    _titulo_barra_superior.font = FONT_BEBAS(22.0f);
    _nombre_ficha.font = FONT_BEBAS(27.0f);
    _tipo_ficha_label.font = FONT_BEBAS(15.0f);
    _info_label.font = FONT_BEBAS(15.0f);
    
    self.imageViews = [[NSMutableArray alloc] init];
    self.mediaFocusManager = [[ASMediaFocusManager alloc] init];
    self.mediaFocusManager.delegate = self;
    
    //Menu Lateral
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 180;
    self.revealViewController.delegate = self;
    

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
                [utils controlarErrores:error];
            }
        }];
    
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
            [utils controlarErrores:error];
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
            [utils controlarErrores:error];
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
                    [_view_scroll addSubview:[constructorVistas construir_scroll_embeds:json posicion:y]];
                    y = y+150;
                }
            }
            
            for(NSDictionary* json in [[json_content objectForKey:@"content"] objectForKey:@"content_gallery_images"]){
                if([[json valueForKey:@"code"] isEqualToString:codigo_sin_corchetes]){
                    [_view_scroll addSubview:[self construir_scroll_images:json posicion:y]];
                    y = y+150;
                }
            }
        }
        else if(![x isEqualToString:@""] && ![x isEqualToString:@"</p>"]){
            UIWebView *myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, y, 320, 400)];
            [myWebView setBackgroundColor:[UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0]];
            NSString *myDescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                           "<head><style type=\"text/css\">body{font-family: \"%@\";color: #555555;text-align: center;}p{color:#555555;font-size: 14px;font-weight: bold;}strong{color:#037c61;}a{color: #037c61;text-decoration: underline;}</style></head><body>%@</body></html>", @"Arial-BoldMT", x];
            [myWebView loadHTMLString:myDescriptionHTML baseURL:nil];
            [myWebView setDelegate:self];
            y = y + myWebView.frame.size.height;
            [_view_scroll addSubview:myWebView];
        }
    }
    [self autoHeight];
    [self show_items_relacionados:json_content];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    CGSize fittingSize = [webView sizeThatFits:webView.scrollView.contentSize];
    frame.size = fittingSize;
    webView.frame = frame;
    [self ordenar_vistas];
}

- (void)ordenar_vistas{
    int y = 484;
    for(UIView* v in _view_scroll.subviews){
        if([v isKindOfClass:[UIWebView class]]){
            CGRect newFrame = v.frame;
            newFrame.origin.y = y;
            v.frame = newFrame;
            y = y + v.frame.size.height;
        }
        else if([v isKindOfClass:[UIScrollView class]] || [v isKindOfClass:[UITextView class]]){
            CGRect newFrame = v.frame;
            newFrame.origin.y = y;
            v.frame = newFrame;
            y = y + v.frame.size.height + 6;
        }
        
    }
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
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
            [_view_scroll addSubview:[self construir_scroll_images:json posicion:y]];
            y = y + 150;
        }
    }
    [self autoHeight];
    [self ordenar_vistas];
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
                                        [_view_scroll addSubview:[constructorVistas scrollLateralItemsPeques:sellos posicion:self.altura_scroll.constant selector:irSellos controllerBase:self]];
                                        [self autoHeight];
                                    }
                                    NSNumber* tipo_entrevista = [[NSNumber alloc] initWithInt:[utils getKind:@"Entrevista"]];
                                    [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_ficha item_id:id_a related_kind:tipo_entrevista limit:@10 page:@1 y:^(NSArray *entrevistas, NSError *error) {
                                        if (!error) {
                                            if([entrevistas count]>0){
                                                [_view_scroll addSubview:[constructorVistas construirTitulo:@"Entrevistas Relacionadas" poscion:self.altura_scroll.constant]];
                                                NSValue *irArticulos = [NSValue valueWithPointer:@selector(verArticulo:)];
                                                [_view_scroll addSubview:[constructorVistas scrollLateral:entrevistas posicion:self.altura_scroll.constant selector:irArticulos controllerBase:self]];
                                                [self autoHeight];
                                            }
                                            [self embeds_finales:json_content];
                                        } else {
                                            [utils controlarErrores:error];
                                        }
                                    }];
                                } else {
                                    [utils controlarErrores:error];
                                }
                            }];
                        } else {
                            [utils controlarErrores:error];
                        }
                    }];
                } else {
                    [utils controlarErrores:error];
                }
            }];
            
        } else {
            [utils controlarErrores:error];
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
    self.altura_scroll.constant = scrollViewHeight - 79 - 79 - 21 + 190;
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
    ultima_busqueda_ficha = @"";
    if(_scroll_view.userInteractionEnabled){
        _scroll_view.userInteractionEnabled = FALSE;
    }
    else{
        _scroll_view.userInteractionEnabled = TRUE;
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
    _scroll_view.userInteractionEnabled = TRUE;
}

- (IBAction)textFieldDidBeginEditing:(id)sender {
    CGRect newFrame = _viewBuscar.frame;
    newFrame.origin.y = DEVICE_SIZE.height - 310;
    _viewBuscar.frame = newFrame;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender
{
    if(![ultima_busqueda_ficha isEqualToString:_textViewBuscar.text]){
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
    if(![ultima_busqueda_ficha isEqualToString:_textViewBuscar.text]){
        ultima_busqueda_ficha = _textViewBuscar.text;
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
                    numero_resultados_ficha++;
                }
                
                [self autoWidthScrollView:scrollViewSearch];
                [self.view addSubview:scrollViewSearch];
                numero_resultados_ficha = 0;
                
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

#pragma mark - ASMediaFocusDelegate
// Returns an image view that represents the media view. This image from this view is used in the focusing animation view. It is usually a small image.
- (UIImageView *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager imageViewForView:(UIView *)view;
{
    return (UIImageView *)view;
}

// Returns the final focused frame for this media view. This frame is usually a full screen frame.
- (CGRect)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager finalFrameForView:(UIView *)view
{
    return self.parentViewController.view.bounds;
}

// Returns the view controller in which the focus controller is going to be added.
// This can be any view controller, full screen or not.
- (UIViewController *)parentViewControllerForMediaFocusManager:(ASMediaFocusManager *)mediaFocusManager
{
    return self.parentViewController;
}

// Returns an URL where the image is stored. This URL is used to create an image at full screen. The URL may be local (file://) or distant (http://).
- (NSURL *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager mediaURLForView:(UIView *)view
{
    NSURL *url;
    url = [NSURL fileURLWithPath:view.restorationIdentifier];
    return url;
}

// Returns the title for this media view. Return nil if you don't want any title to appear.
- (NSString *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager titleForView:(UIView *)view
{
    return @"";
}

- (void) image:(NSDictionary *)image unElemento:(bool)unElemento en:(UIScrollView*)scrollView{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    imageView.restorationIdentifier =[image objectForKey:@"image"];
    [imageView setTag:5];
    [utils downloadImageWithURL:[NSURL URLWithString:[image objectForKey:@"image"]] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            int anchura_embed = 240;
            int altura_embed = 160;
            CGFloat p = 0.0f;
            if(unElemento){
                anchura_embed = 270;
                altura_embed = 184;
                p = 30;
            }
            UIImage* new_image = [constructorVistas imageWithImage:image
                                                  scaledToMaxWidth:anchura_embed
                                                         maxHeight:altura_embed];
            for(UIView* v in scrollView.subviews){
                if(v.frame.size.width>10){
                    p = p + v.frame.size.width+5 ;
                }
            }
            if(p==0){
                p=2;
            }
            imageView.frame = CGRectMake(p, 0, new_image.size.width, new_image.size.height);
            [imageView setImage:image];
            imageView.userInteractionEnabled = YES;
            [scrollView addSubview:imageView];
            CGFloat scrollViewWidth = 0.0f;
            for (UIWebView* view in scrollView.subviews)
            {
                scrollViewWidth += view.frame.size.width;
            }
            [scrollView setContentSize:(CGSizeMake(scrollViewWidth, 150))];
            [self.imageViews addObject:imageView];
            [self.mediaFocusManager installOnViews:self.imageViews];
        }
    }];
}

- (UIScrollView*)construir_scroll_images:(NSDictionary*) json posicion:(int) posicion{
    UIScrollView* scrollLateral = [[UIScrollView alloc] initWithFrame:CGRectMake(0, posicion, 320, 170)];
    scrollLateral.tag= 15;
    [scrollLateral setBackgroundColor:[UIColor colorWithRed: 233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0]];
    
    for(NSDictionary* image in [json objectForKey:@"images"]){
        [self image:image unElemento:[[json objectForKey:@"images"] count]==1 en:scrollLateral];
    }
    return scrollLateral;
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


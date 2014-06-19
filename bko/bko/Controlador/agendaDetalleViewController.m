//
//  agendaDetalleViewController.m
//  bko
//
//  Created by Tito Español Gamón on 25/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "agendaDetalleViewController.h"
#import "SWRevealViewController.h"
#import "sesion.h"
#import "party_dao.h"
#import "register_dao.h"
#import <MapKit/MapKit.h>
#import "constructorVistas.h"
#import "utils.h"
#import "articles_dao.h"
#import "fichaViewController.h"
#import "actualidadDetalleViewController.h"
#import "actualidadIndexViewController.h"
#import "agendaIndexViewController.h"
#import "sorteosIndexViewController.h"
#import "sinConexionViewController.h"

@interface agendaDetalleViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titulo_foto_label;
@property (weak, nonatomic) IBOutlet UILabel *hora_label;
@property (weak, nonatomic) IBOutlet UILabel *localizacion_label;
@property (weak, nonatomic) IBOutlet UIView *modal_plan_anadido;
@property (weak, nonatomic) IBOutlet UILabel *precioLabel;
@property (weak, nonatomic) IBOutlet UILabel *cuandoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imagen;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll_view;
@property (strong, nonatomic) NSString* link_comprar;
@property (strong, nonatomic) NSString* link_apuntarse;
@property (weak, nonatomic) IBOutlet UIButton *button_anadir_a_mis_planes;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *altura_vista;
@property (weak, nonatomic) IBOutlet UIView *view_scroll;
@property (weak, nonatomic) IBOutlet UIView *view_no_es_posible_apuntarse;
@property (strong) NSString* texto_mapa;
@property (weak, nonatomic) IBOutlet UIButton *button_coordenadas;
@property (weak, nonatomic) IBOutlet UIImageView *icono_donde;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@property (strong, nonatomic) NSString *raffle_author;
@property (strong, nonatomic) NSString *raffle;
@property (weak, nonatomic) IBOutlet UILabel *raffle_author_label;
@property (weak, nonatomic) IBOutlet UILabel *raffle_sortea_label;
@property (weak, nonatomic) IBOutlet UILabel *raffle_title_label;
@property (weak, nonatomic) IBOutlet UIView *entrado_sorteo_modal;
@property (weak, nonatomic) IBOutlet UIView *vista_agenda_info;

@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation agendaDetalleViewController

@synthesize id_party;

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
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 180;
    self.revealViewController.delegate = self;
    
    self.imageViews = [[NSMutableArray alloc] init];
    self.mediaFocusManager = [[ASMediaFocusManager alloc] init];
    self.mediaFocusManager.delegate = self;
    
    sesion *s = [sesion sharedInstance];
    NSNumber* id_p = [NSNumber numberWithInteger:id_party];
    [[party_dao sharedInstance] getParty:s.codigo_conexion item_id:id_p y:^(NSArray *party, NSError *error){
        if (!error) {
            NSDictionary* party_json = [party objectAtIndex:0];
            
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            
            NSNumber *id_sitio =[f numberFromString:[[party_json objectForKey:@"place"] objectForKey:@"id" ]];
            
            UIButton *buttonLugar = [[UIButton alloc] initWithFrame:CGRectMake(150, 1, 160, 21)];
            [_vista_agenda_info addSubview:buttonLugar];
            [buttonLugar addTarget:self action:@selector(ir_a_ficha_sitio:) forControlEvents:UIControlEventTouchUpInside];
            [buttonLugar setTag:[id_sitio intValue]];
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[party_json valueForKey:@"img"]]];
            [_imagen setImage:[UIImage imageWithData:imageData]];
            NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [f setLocale: us];
            NSNumber *precio =[f numberFromString:[party_json valueForKey:@"price"]];
            _precioLabel.text = [[utils quitarDecimales:precio] stringByAppendingString:@"€"];
            _texto_mapa = [party_json valueForKey:@"name"];
            _cuandoLabel.text = [utils fechaConFormatoAgenda:[party_json valueForKey:@"start_date"]];
            _titulo_foto_label.text = [party_json valueForKey:@"name"];
            _hora_label.text = [utils horaFromString:[party_json valueForKey:@"start_date"]];
            _localizacion_label.text = [[party_json valueForKey:@"place"] valueForKey:@"name"];
            [_localizacion_label sizeToFit];
            _raffle = [[NSString alloc] init];
            _raffle = nil;
            if([party_json valueForKey:@"raffle"]!= nil){
                _raffle_author = [[NSString alloc] init];
                _raffle_author = [[party_json valueForKey:@"raffle"] valueForKey:@"author"];
                _raffle = [[party_json valueForKey:@"raffle"] valueForKey:@"title"];
            }
            
            [_icono_donde setTranslatesAutoresizingMaskIntoConstraints:YES];
            [_localizacion_label setTranslatesAutoresizingMaskIntoConstraints:YES];
            CGRect frame = _icono_donde.frame;
            frame.origin.x = 300 - _localizacion_label.frame.size.width;
            _icono_donde.frame = frame;
            
            frame = _localizacion_label.frame;
            frame.origin.x = 310 - _localizacion_label.frame.size.width;
            _localizacion_label.frame = frame;
            
            _link_apuntarse = [[NSString alloc] init];
            _link_comprar = [[NSString alloc] init];
            _link_apuntarse = [party_json valueForKey:@"list_link"];
            _link_comprar = [party_json valueForKey:@"tickets_link"];
            if([[party_json valueForKey:@"is_planned"] boolValue]){
                [_button_anadir_a_mis_planes setImage:[UIImage imageNamed:@"5_button_QUITAR_PLANES.png"] forState:UIControlStateNormal];
                _button_anadir_a_mis_planes.tag = 1;
            }
            else{
                _button_anadir_a_mis_planes.tag = 0;
            }
            
            [self autoHeight];
            [self construir_contenido:party_json];
        } else {
            [utils controlarErrores:error];
        }
    }];
    
    if([s.latitude intValue] == 0){
        [self shakeView];
    }
    else{
        _button_coordenadas.hidden = TRUE;
    }
    
    _titulo_foto_label.font = FONT_BEBAS(17.0f);
    _precioLabel.font = FONT_BEBAS(17.0f);
    _cuandoLabel.font = FONT_BEBAS(17.0f);
    _hora_label.font = FONT_BEBAS(15.0f);
    _localizacion_label.font = FONT_BEBAS(15.0f);
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

- (void)embeds_finales:(NSDictionary*)json_content{
    //int y = self.altura_vista.constant;
    int y =  _view_scroll.frame.size.height;

    
    [self autoHeight];
    //Construimos lo restante
    UIView* titulonformacion = [constructorVistas construirTituloOscuro:@"Informacion" poscion:self.altura_vista.constant];
    titulonformacion.tag=7;
    UIView* viewInformacion = [UIView new];
    viewInformacion.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_view_scroll addSubview:titulonformacion];
    [_view_scroll addSubview:viewInformacion];
    viewInformacion.tag = 7;
    int altura_informacion = 8;
    if([json_content valueForKey:@"price_text"]!=nil && ![[json_content valueForKey:@"price_text"] isEqualToString:@""]){
        UIImageView *priceCode = [[UIImageView alloc] initWithFrame:CGRectMake(10, altura_informacion, 83, 31)];
        [priceCode setImage:[UIImage imageNamed:@"5_icon_PRECIO_ENTRADA.png"]];
        UILabel* priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, altura_informacion + 8, 200, 21)];
        priceLabel.text = [json_content valueForKey:@"price_text"];
        priceLabel.font = FONT_BEBAS(15.0f);
        [viewInformacion addSubview:priceCode];
        [viewInformacion addSubview:priceLabel];
        altura_informacion = altura_informacion + 36;
    }
    if([json_content valueForKey:@"schedule_text"]!=nil && ![[json_content valueForKey:@"schedule_text"] isEqualToString:@""]){
        UIImageView *scheduleCode = [[UIImageView alloc] initWithFrame:CGRectMake(10, altura_informacion, 62, 31)];
        [scheduleCode setImage:[UIImage imageNamed:@"5_icon_HORARIO.png"]];
        UILabel* scheduleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, altura_informacion+8, 200, 21)];
        scheduleLabel.text = [json_content valueForKey:@"schedule_text"];
        scheduleLabel.font = FONT_BEBAS(15.0f);
        [viewInformacion addSubview:scheduleCode];
        [viewInformacion addSubview:scheduleLabel];
        altura_informacion = altura_informacion + 36;
    }
    if([json_content valueForKey:@"dresscode_text"]!=nil && ![[json_content valueForKey:@"dresscode_text"] isEqualToString:@""]){
        UIImageView *dressCode = [[UIImageView alloc] initWithFrame:CGRectMake(10,altura_informacion, 69, 31)];
        [dressCode setImage:[UIImage imageNamed:@"5_icon_DRESSCODE.png"]];
        UILabel* dressLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, altura_informacion+8, 200, 21)];
        dressLabel.text = [json_content valueForKey:@"dresscode_text"];
        dressLabel.font = FONT_BEBAS(15.0f);
        [viewInformacion addSubview:dressCode];
        [viewInformacion addSubview:dressLabel];
        altura_informacion = altura_informacion + 36;
    }
    if([json_content valueForKey:@"address_text"]!=nil && ![[json_content valueForKey:@"address_text"] isEqualToString:@""]){
        UIImageView *addressCode = [[UIImageView alloc] initWithFrame:CGRectMake(10, altura_informacion, 66, 31)];
        [addressCode setImage:[UIImage imageNamed:@"5_icon_direccion.png"]];
        UILabel* addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, altura_informacion+8, 200, 21)];
        addressLabel.text = [json_content valueForKey:@"address_text"];
        addressLabel.font = FONT_BEBAS(15.0f);
        [viewInformacion addSubview:addressCode];
        [viewInformacion addSubview:addressLabel];
        altura_informacion = altura_informacion + 36;
    }
    altura_informacion = altura_informacion;
    MKMapView* mapa = [[MKMapView alloc] initWithFrame:CGRectMake(0, altura_informacion, 320, 170)];
    [self showMap:[[json_content valueForKey:@"lat"] doubleValue] longitude: [[json_content valueForKey:@"lng"] doubleValue] mapa:mapa en:viewInformacion];
    //[self autoHeight];
    altura_informacion = altura_informacion + 190;
    if(![_link_apuntarse isEqualToString:@""]){
        UIButton *buttonApuntarse = [[UIButton alloc] initWithFrame:CGRectMake(0, altura_informacion, 320, 46)];
        [buttonApuntarse setBackgroundImage:[UIImage imageNamed:@"5_button_APUNTARSE_LISTA.png"] forState:UIControlStateNormal];
        [buttonApuntarse addTarget:self action:@selector(apuntarse_lista:) forControlEvents:UIControlEventTouchUpInside];
        [viewInformacion addSubview:buttonApuntarse];
        altura_informacion = altura_informacion + 48;
        buttonApuntarse.tag=7;
    }
    if(![_link_comprar isEqualToString:@""]){
        UIButton *buttonComprar = [[UIButton alloc] initWithFrame:CGRectMake(0,     altura_informacion, 320, 46)];
        [buttonComprar setBackgroundImage:[UIImage imageNamed:@"5_button_COMPRAR_ENTRADAS.png"] forState:UIControlStateNormal];
        [buttonComprar addTarget:self action:@selector(comprar_entradas:) forControlEvents:UIControlEventTouchUpInside];
        [viewInformacion addSubview:buttonComprar];
        altura_informacion = altura_informacion + 48;
        buttonComprar.tag=7;
    }
    float w = 0;
    float h = 0;
    for (UIView *v in [viewInformacion subviews]) {
        float fw = v.frame.origin.x + v.frame.size.width;
        float fh = v.frame.origin.y + v.frame.size.height;
        w = MAX(fw, w);
        h = MAX(fh, h);
    }
    [viewInformacion setFrame:CGRectMake(viewInformacion.frame.origin.x, viewInformacion.frame.origin.y, w, h+5)];
    
    
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
    
    
    [self ordenar_vistas];
}


- (void)construir_contenido:(NSDictionary*)json_content{
    //Creamos el contenido de la descripción
    NSMutableArray* parts=[utils generarContenidoDescripcion:[[json_content objectForKey:@"content"] objectForKey:@"content"]];
    int y = 270;
    for (NSString* x in parts){
        
        if([[x substringToIndex:2] isEqual:@"{{"]){
            NSString* codigo_sin_corchetes = [x substringFromIndex:2];
            codigo_sin_corchetes = [codigo_sin_corchetes substringToIndex:codigo_sin_corchetes.length -2];
            for(NSDictionary* json in [[json_content objectForKey:@"content"] objectForKey:@"content_gallery_embeds"]){
                if([[json valueForKey:@"code"] isEqualToString:codigo_sin_corchetes]){
                    [_view_scroll addSubview:[constructorVistas construir_scroll_embeds:json posicion:y]];
                    y = y+160;
                }
            }
            for(NSDictionary* json in [[json_content objectForKey:@"content"] objectForKey:@"content_gallery_images"]){
                if([[json valueForKey:@"code"] isEqualToString:codigo_sin_corchetes]){
                    [_view_scroll addSubview:[self construir_scroll_images:json posicion:y]];
                    y = y+160;
                }
            }
        }
        else if(![x isEqualToString:@""] && ![x isEqualToString:@"</p>"]){
            UIWebView *myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, y, 320, 50)];
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
    int y = 270;
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
            y = y + v.frame.size.height;
        }
        else if([v tag]==7){
            CGRect newFrame = v.frame;
            newFrame.origin.y = y;
            v.frame = newFrame;
            y = y + v.frame.size.height;
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

- (void)show_items_relacionados:(NSDictionary*)json_content{
    
    sesion *s = [sesion sharedInstance];
    NSNumber* tipo_artistas = [[NSNumber alloc] initWithInt:[utils getKind:@"Artist"]];
    NSNumber* tipo_fiesta = [[NSNumber alloc] initWithInt:[utils getKind:@"Fiesta"]];
    NSNumber* id_a = [[NSNumber alloc] initWithInt:id_party];
    [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_fiesta item_id:id_a related_kind:tipo_artistas limit:@10 page:@1 y:^(NSArray *artistas, NSError *error) {
        if (!error) {
            if([artistas count]>0){
                [_view_scroll addSubview:[constructorVistas construirTitulo:@"Line Up" poscion:_view_scroll.frame.size.height]];
                NSValue *irArtistas = [NSValue valueWithPointer:@selector(verArtista:)];
                [_view_scroll addSubview:[constructorVistas scrollLateral:artistas posicion:_view_scroll.frame.size.height selector:irArtistas controllerBase:self]];
                [self autoHeight];
                [self embeds_finales:json_content];
                [self autoHeight];
            }
            NSNumber* tipo_sitio = [[NSNumber alloc] initWithInt:[utils getKind:@"Sitio"]];
            [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_fiesta item_id:id_a related_kind:tipo_sitio limit:@10 page:@1 y:^(NSArray *sitios, NSError *error) {
                if (!error) {
                    if([sitios count]>0){
                        [_view_scroll addSubview:[constructorVistas construirTitulo:@"Sitios Relacionados" poscion:_view_scroll.frame.size.height]];
                        NSValue *irSitios = [NSValue valueWithPointer:@selector(verSitio:)];
                        [_view_scroll addSubview:[constructorVistas scrollLateral:sitios posicion:_view_scroll.frame.size.height selector:irSitios controllerBase:self]];
                        [self autoHeight];
                    }
                    NSNumber* tipo_articulos = [[NSNumber alloc] initWithInt:[utils getKind:@"Artículo"]];
                    [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_fiesta item_id:id_a related_kind:tipo_articulos limit:@10 page:@1 y:^(NSArray *articulos, NSError *error) {
                        if (!error) {
                            if([articulos count]>0){
                                [_view_scroll addSubview:[constructorVistas construirTitulo:@"Artículos Relacionados" poscion:_view_scroll.frame.size.height]];
                                NSValue *irArticulos = [NSValue valueWithPointer:@selector(verArticulo:)];
                                [_view_scroll addSubview:[constructorVistas scrollLateral:articulos posicion:_view_scroll.frame.size.height selector:irArticulos controllerBase:self]];
                                [self autoHeight];
                            }
                            NSNumber* tipo_sello = [[NSNumber alloc] initWithInt:[utils getKind:@"Sello"]];
                            [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_fiesta item_id:id_a related_kind:tipo_sello limit:@10 page:@1 y:^(NSArray *sellos, NSError *error) {
                                if (!error) {
                                    if([sellos count]>0){
                                        [_view_scroll addSubview:[constructorVistas construirTitulo:@"Sellos Relacionados" poscion:_view_scroll.frame.size.height]];
                                        NSValue *irSellos = [NSValue valueWithPointer:@selector(verSello:)];
                                        [_view_scroll addSubview:[constructorVistas scrollLateralItemsPeques:sellos posicion:_view_scroll.frame.size.height selector:irSellos controllerBase:self]];
                                        [self autoHeight];
                                    }
                                    NSNumber* tipo_entrevista = [[NSNumber alloc] initWithInt:[utils getKind:@"Entrevista"]];
                                    [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_fiesta item_id:id_a related_kind:tipo_entrevista limit:@10 page:@1 y:^(NSArray *entrevistas, NSError *error) {
                                        if (!error) {
                                            if([entrevistas count]>0){
                                                [_view_scroll addSubview:[constructorVistas construirTitulo:@"Entrevistas Relacionadas" poscion:_view_scroll.frame.size.height]];
                                                NSValue *irArticulos = [NSValue valueWithPointer:@selector(verArticulo:)];
                                                [_view_scroll addSubview:[constructorVistas scrollLateral:entrevistas posicion:_view_scroll.frame.size.height selector:irArticulos controllerBase:self]];
                                                [self autoHeight];
                                            }
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
                                        [self ordenar_vistas];
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
    self.altura_vista.constant = scrollViewHeight-21-35-35;
}


-(void)apuntarse_lista:(UIButton*)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_link_apuntarse]];
}
-(void)comprar_entradas:(UIButton*)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_link_comprar]];
}
- (IBAction)anadir_a_mis_planes:(id)sender {
    sesion *s = [sesion sharedInstance];
    NSNumber* id_p = [NSNumber numberWithInteger:id_party];
    if (_button_anadir_a_mis_planes.tag==0) {
        [[party_dao sharedInstance] addPlan:s.codigo_conexion item_id:id_p y:^(NSArray *party, NSError *error){
         if (!error) {
             if([[party objectAtIndex:0] boolValue]){
                 [_button_anadir_a_mis_planes setImage:[UIImage imageNamed:@"5_button_QUITAR_PLANES.png"] forState:UIControlStateNormal];
                 _button_anadir_a_mis_planes.tag = 1;
                 if(![_raffle isEqual:[NSNull null]]){
                     if(![_raffle isEqualToString:@""]){
                     _raffle_author_label.font = FONT_BEBAS(17.0f);
                     _raffle_sortea_label.font = FONT_BEBAS(17.0f);
                     _raffle_title_label.font = FONT_BEBAS(17.0f);
                     _raffle_author_label.text = _raffle_author;
                     _raffle_title_label.text = _raffle;
                     _entrado_sorteo_modal.hidden = FALSE;
                     [NSTimer scheduledTimerWithTimeInterval:8.0
                                                      target:self
                                                    selector:@selector(aTime)
                                                    userInfo:nil
                                                     repeats:NO];
                     UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(aTime)];
                     [_entrado_sorteo_modal addGestureRecognizer:tapRecognizer];
                     }
                 }
                 else{
                     _modal_plan_anadido.hidden = false;
                     [NSTimer scheduledTimerWithTimeInterval:8.0
                                                  target:self
                                                selector:@selector(aTime)
                                                userInfo:nil
                                                 repeats:NO];
                     UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(aTime)];
                     [_modal_plan_anadido addGestureRecognizer:tapRecognizer];
                    }
                 }
                 else{
                     _view_no_es_posible_apuntarse.hidden = false;
                     [NSTimer scheduledTimerWithTimeInterval:8.0
                                                      target:self
                                                    selector:@selector(aTime)
                                                    userInfo:nil
                                                     repeats:NO];
                     UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(aTime)];
                     [_view_no_es_posible_apuntarse addGestureRecognizer:tapRecognizer];
                     _button_anadir_a_mis_planes.tag = 0;
                 
             }
         } else {
             [utils controlarErrores:error];
         }
         }];
    } else {
        [[party_dao sharedInstance] removePlan:s.codigo_conexion item_id:id_p y:^(NSArray *party, NSError *error){
            if (!error) {
                [_button_anadir_a_mis_planes setImage:[UIImage imageNamed:@"5_button_ANADIR_PLANES.png"] forState:UIControlStateNormal];
                _button_anadir_a_mis_planes.tag = 0;
            } else {
                [utils controlarErrores:error];
            }
        }];
    }
}

- (void)showMap:(double)latitude longitude:(double)longitude mapa:(MKMapView*) mapa en: (UIView*)view
{
    [view insertSubview:mapa atIndex:20 ];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = latitude;
    zoomLocation.longitude= longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 2000, 2000);
    MKPointAnnotation *mark = [[MKPointAnnotation alloc] init];
    mark.coordinate = zoomLocation;
    mark.title = _texto_mapa;
    [mapa addAnnotation:mark];
    [mapa setRegion:viewRegion animated:YES];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(10, 10, 120, 160);
    button.tag = 7;
    [mapa addSubview:button];
    [view addSubview:button];
    [self autoHeight];
}

-(void)ir_a_ficha_sitio:(UIButton*)sender
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

-(void)aTime
{
    _modal_plan_anadido.hidden = true;
    _view_no_es_posible_apuntarse.hidden = true;
    _entrado_sorteo_modal.hidden = true;
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

- (IBAction)guardar_coordenadas:(id)sender {
    [locationManager startUpdatingLocation];
}

- (IBAction)back:(id)sender {
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
            CGFloat posicion = 0.0f;
            if(unElemento){
                anchura_embed = 270;
                altura_embed = 184;
                posicion = 30;
            }
            UIImage* new_image = [constructorVistas imageWithImage:image
                                                  scaledToMaxWidth:anchura_embed
                                                         maxHeight:altura_embed];
            for(UIView* v in scrollView.subviews){
                if(v.frame.size.width>10){
                    posicion = posicion + v.frame.size.width+5 ;
                }
            }
            if(posicion==0){
                posicion=2;
            }
            imageView.frame = CGRectMake(posicion, 0, new_image.size.width, new_image.size.height);
            [imageView setImage:image];
            imageView.userInteractionEnabled = YES;
            [scrollView addSubview:imageView];
            CGFloat scrollViewWidth = 0.0f;
            for (UIWebView* view in scrollView.subviews)
            {
                scrollViewWidth += view.frame.size.width;
            }
            [scrollView setContentSize:(CGSizeMake(scrollViewWidth, 150))];
            imageView.userInteractionEnabled = YES;
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

//
//  actualidadDetalleViewController.m
//  bko
//
//  Created by Tito Español Gamón on 21/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "actualidadDetalleViewController.h"
#import "articles_dao.h"
#import "sesion.h"
#import "utils.h"
#import "register_dao.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>
#import "fichaViewController.h"
#import "constructorVistas.h"
#import "actualidadIndexViewController.h"
#import "agendaIndexViewController.h"
#import "sorteosIndexViewController.h"

@interface actualidadDetalleViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titulo_label;
@property (weak, nonatomic) IBOutlet UILabel *autor_label;
@property (weak, nonatomic) IBOutlet UILabel *date_label;
@property (weak, nonatomic) IBOutlet UILabel *numero_shares_label;
@property (weak, nonatomic) IBOutlet UILabel *likes_label;
@property (weak, nonatomic) IBOutlet UILabel *titulo_compartir_label;
@property (weak, nonatomic) IBOutlet UILabel *indica_como_compartir_label;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll_view;
@property (weak, nonatomic) IBOutlet UIImageView *imagen;
@property (weak, nonatomic) IBOutlet UIView *compartir_modal;
@property (weak, nonatomic) IBOutlet UIButton *buttonFb;
@property (weak, nonatomic) IBOutlet UIButton *buttonTw;
@property (weak, nonatomic) IBOutlet UIButton *buttonMail;
@property (weak, nonatomic) IBOutlet UIImageView *imageModal;
@property (weak, nonatomic) IBOutlet UIButton *buttonLike;
@property (weak, nonatomic) IBOutlet UIView *view_scroll;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *altura_scroll;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@end

@implementation actualidadDetalleViewController

@synthesize id_articulo;

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
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    [self.navigationController setNavigationBarHidden:YES];
    // Do any additional setup after loading the view.
    _titulo_label.font = FONT_BEBAS(18.0f);
    _autor_label.font = FONT_BEBAS(16.0f);
    _date_label.font = FONT_BEBAS(16.0f);
    _numero_shares_label.font = FONT_BEBAS(24.0f);
    _likes_label.font = FONT_BEBAS(24.0f);
    _titulo_compartir_label.font = FONT_BEBAS(18.0f);
    _indica_como_compartir_label.font = FONT_BEBAS(16.0f);
    _compartir_modal.hidden = true;
    
    sesion *s = [sesion sharedInstance];
    NSNumber* id_art = [NSNumber numberWithInteger:id_articulo];
    [[articles_dao sharedInstance] getArticle:s.codigo_conexion item_id:id_art y:^(NSArray *article, NSError *error){
        if (!error) {
            NSDictionary* article_json = [article objectAtIndex:0];
            _titulo_label.text = [article_json objectForKey:@"title"];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[article_json valueForKey:@"img"]]];
            [_imagen setImage:[UIImage imageWithData:imageData]];
            _autor_label.text = [article_json objectForKey:@"author"];
            _numero_shares_label.text = [[article_json objectForKey:@"shares_count"] stringValue];
            _likes_label.text = [[article_json objectForKey:@"likes_count"] stringValue];
            _date_label.text = [article_json objectForKey:@"date"];
            [_imageModal setImage:[UIImage imageWithData:imageData]];
            _titulo_compartir_label.text = [article_json objectForKey:@"title"];
            bool seleccionado = [[article_json objectForKey:@"is_liked"] boolValue];
            
            [self construir_contenido:article_json];
            
            _scroll_view.scrollEnabled = YES;
            
            if(seleccionado == TRUE){
                [_buttonLike setImage:[UIImage imageNamed:@"button_LIKE_S.png"] forState:UIControlStateNormal];
                [_buttonLike setTintColor:[UIColor colorWithRed:0/255.0f green:132/255.0f blue:104/255.0f alpha:1.0]];
            }
            else{
                [_buttonLike addTarget:self
                                action:@selector(like:)
                      forControlEvents:UIControlEventTouchUpInside];
            }
        } else {
            // Error hacer al recoger Artículo
            NSLog(@"Error al recoger el artículo: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
    }];
}
- (void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)construir_contenido:(NSDictionary*)json_content{
    //Creamos el contenido de la descripción
    NSMutableArray* parts=[utils generarContenidoDescripcion:[[json_content objectForKey:@"content"] objectForKey:@"content"]];
    int y = 182;
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
            UITextView *myTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, y, 320, 400)];
            [myTextView setUserInteractionEnabled:NO];
            [myTextView setBackgroundColor:[UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0]];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[x dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            UIFont *font=[UIFont fontWithName:@"Arial-BoldMT" size:14.0f];
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
    NSNumber* tipo_articulo = [[NSNumber alloc] initWithInt:[utils getKind:@"Artículo"]];
    NSNumber* id_a = [[NSNumber alloc] initWithInt:id_articulo];
    [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_articulo item_id:id_a related_kind:tipo_artistas limit:@10 page:@1 y:^(NSArray *artistas, NSError *error) {
        if (!error) {
            if([artistas count]>0){
                [_view_scroll addSubview:[constructorVistas construirTitulo:@"Artistas Relacionados" poscion:_view_scroll.frame.size.height]];
                NSValue *irArtistas = [NSValue valueWithPointer:@selector(verArtista:)];
                [_view_scroll addSubview:[constructorVistas scrollLateral:artistas posicion:_view_scroll.frame.size.height selector:irArtistas controllerBase:self]];
                [self autoHeight];
            }
            NSNumber* tipo_sitio = [[NSNumber alloc] initWithInt:[utils getKind:@"Sitio"]];
            [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_articulo item_id:id_a related_kind:tipo_sitio limit:@10 page:@1 y:^(NSArray *sitios, NSError *error) {
                if (!error) {
                    if([sitios count]>0){
                        [_view_scroll addSubview:[constructorVistas construirTitulo:@"Sitios Relacionados" poscion:_view_scroll.frame.size.height]];
                        NSValue *irSitios = [NSValue valueWithPointer:@selector(verSitio:)];
                        [_view_scroll addSubview:[constructorVistas scrollLateral:sitios posicion:_view_scroll.frame.size.height selector:irSitios controllerBase:self]];
                        [self autoHeight];
                    }
                    NSNumber* tipo_articulos = [[NSNumber alloc] initWithInt:[utils getKind:@"Artículo"]];
                    [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_articulo item_id:id_a related_kind:tipo_articulos limit:@10 page:@1 y:^(NSArray *articulos, NSError *error) {
                        if (!error) {
                            if([articulos count]>0){
                                [_view_scroll addSubview:[constructorVistas construirTitulo:@"Artículos Relacionados" poscion:_view_scroll.frame.size.height]];
                                NSValue *irArticulos = [NSValue valueWithPointer:@selector(verArticulo:)];
                                [_view_scroll addSubview:[constructorVistas scrollLateral:articulos posicion:_view_scroll.frame.size.height selector:irArticulos controllerBase:self]];
                                [self autoHeight];
                            }
                            NSNumber* tipo_sello = [[NSNumber alloc] initWithInt:[utils getKind:@"Sello"]];
                            [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_articulo item_id:id_a related_kind:tipo_sello limit:@10 page:@1 y:^(NSArray *sellos, NSError *error) {
                                if (!error) {
                                    if([sellos count]>0){
                                        [_view_scroll addSubview:[constructorVistas construirTitulo:@"Sellos Relacionados" poscion:_view_scroll.frame.size.height]];
                                        NSValue *irSellos = [NSValue valueWithPointer:@selector(verSello:)];
                                        [_view_scroll addSubview:[constructorVistas scrollLateralItemsPeques:articulos posicion:_view_scroll.frame.size.height selector:irSellos controllerBase:self]];
                                        [self autoHeight];
                                    }
                                    NSNumber* tipo_entrevista = [[NSNumber alloc] initWithInt:[utils getKind:@"Entrevista"]];
                                    [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_articulo item_id:id_a related_kind:tipo_entrevista limit:@10 page:@1 y:^(NSArray *entrevistas, NSError *error) {
                                        if (!error) {
                                            if([entrevistas count]>0){
                                                [_view_scroll addSubview:[constructorVistas construirTitulo:@"Entrevistas Relacionadas" poscion:_view_scroll.frame.size.height]];
                                                NSValue *irArticulos = [NSValue valueWithPointer:@selector(verArticulo:)];
                                                [_view_scroll addSubview:[constructorVistas scrollLateral:articulos posicion:_view_scroll.frame.size.height selector:irArticulos controllerBase:self]];
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
    self.altura_scroll.constant = scrollViewHeight-68-21-21;
}


- (IBAction)tweet:(id)sender {
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:_titulo_label.text];
    [self presentViewController:tweetSheet animated:YES completion:nil];
}

- (IBAction)mail:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setToRecipients:[NSArray arrayWithObjects: @"",nil]];
        [mailComposer setSubject:[NSString stringWithFormat: @"MailMe Support"]];
        NSString *supportText = [NSString stringWithFormat:@"Device: "];
        supportText = [supportText stringByAppendingString: @"Please describe your problem or question."];
        [mailComposer setMessageBody:supportText isHTML:NO];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)facebook:(id)sender {
    SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [mySLComposerSheet setInitialText:_titulo_label.text];
    
    [mySLComposerSheet addImage:_imagen.image];
    
    //[mySLComposerSheet addURL:[NSURL URLWithString:@""]];
    
    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                NSLog(@"Post Cancelado");
                break;
            case SLComposeViewControllerResultDone:
                NSLog(@"Post Exitoso");
                break;
                
            default:
                break;
        }
    }];
    
    [self presentViewController:mySLComposerSheet animated:YES completion:nil];
}
- (void)like:(id)sender {
    
    NSNumber* dos = [[NSNumber alloc] initWithInt:2];
    NSNumber* cinco = [[NSNumber alloc] initWithInt:5];
    NSNumber* id_a = [[NSNumber alloc] initWithInt:id_articulo];
    sesion *s = [sesion sharedInstance];
        [[register_dao sharedInstance] setLiked:s.codigo_conexion kind:cinco item_id:id_a like_kind:dos y:^(NSArray *artists, NSError *error){
            if (!error) {
                [_buttonLike setImage:[UIImage imageNamed:@"button_LIKE_S.png"] forState:UIControlStateNormal];
                [_buttonLike setTintColor:[UIColor colorWithRed:0/255.0f green:132/255.0f blue:104/255.0f alpha:1.0]];
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

- (void)viewDidLayoutSubviews {
}

- (IBAction)compartir:(id)sender {
    _compartir_modal.hidden = false;
}

- (IBAction)cerrarCompartir:(id)sender {
    _compartir_modal.hidden = true;
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
            [self.navigationController setNavigationBarHidden:NO];
            [self.navigationController pushViewController:actualidadController animated:YES];
		} else if (index == 2) {
            //Se hace click en el label de agenda
            
            agendaIndexViewController *agendaController =
            [storyboard instantiateViewControllerWithIdentifier:@"agendaIndexViewController"];
            [self.navigationController setNavigationBarHidden:NO];
            [self.navigationController pushViewController:agendaController animated:YES];
			
		} else if (index == 3) {
            //Se hace click en el label de sorteos
            
            sorteosIndexViewController *sorteosController =
            [storyboard instantiateViewControllerWithIdentifier:@"sorteosIndexViewController"];
            [self.navigationController setNavigationBarHidden:NO];
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

/*- (void)unlike:(id)sender {
 
 NSNumber* dos = [[NSNumber alloc] initWithInt:2];
 NSNumber* cinco = [[NSNumber alloc] initWithInt:5];
 NSNumber* id_a = [[NSNumber alloc] initWithInt:id_articulo];
 sesion *s = [sesion sharedInstance];
 [[register_dao sharedInstance] setUnliked:s.codigo_conexion kind:cinco item_id:id_a like_kind:dos y:^(NSArray *artists, NSError *error){
 
 if (!error) {
 [_buttonLike setImage:[UIImage imageNamed:@"button_LIKE.png"] forState:UIControlStateNormal];
 [_buttonLike setTintColor:[UIColor colorWithRed:0/255.0f green:132/255.0f blue:104/255.0f alpha:1.0]];
 [_buttonLike addTarget:self
 action:@selector(like:)
 forControlEvents:UIControlEventTouchUpInside];
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
 }*/

@end

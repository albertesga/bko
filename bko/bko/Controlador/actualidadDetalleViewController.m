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
#import "sinConexionViewController.h"

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
@property (weak, nonatomic) IBOutlet UITextField *textViewBuscar;
@property (weak, nonatomic) IBOutlet UIView *viewBuscar;
@end

@implementation actualidadDetalleViewController

@synthesize id_articulo;
int numero_resultados_detalle = 0;
NSString* ultima_busqueda_detalle = @"";
static NSString *url = @"url";

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
    _scroll_view.hidden = TRUE;
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    [self.navigationController setNavigationBarHidden:YES];
    // Do any additional setup after loading the view.
    _titulo_label.font = FONT_BEBAS(18.0f);
    _autor_label.font = FONT_BEBAS(15.0f);
    _date_label.font = FONT_BEBAS(15.0f);
    _numero_shares_label.font = FONT_BEBAS(24.0f);
    _likes_label.font = FONT_BEBAS(24.0f);
    _titulo_compartir_label.font = FONT_BEBAS(18.0f);
    _indica_como_compartir_label.font = FONT_BEBAS(16.0f);
    _compartir_modal.hidden = true;
    
    [_viewBuscar setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.textViewBuscar.delegate=self;
    
    self.mediaFocusManager = [[ASMediaFocusManager alloc] init];
    self.mediaFocusManager.delegate = self;
    self.imageViews = [[NSMutableArray alloc] init];
    
    sesion *s = [sesion sharedInstance];
    NSNumber* id_art = [NSNumber numberWithInteger:id_articulo];
    [[articles_dao sharedInstance] getArticle:s.codigo_conexion item_id:id_art y:^(NSArray *article, NSError *error){
        if (!error) {
            NSDictionary* article_json = [article objectAtIndex:0];
            _titulo_label.text = [article_json objectForKey:@"title"];
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [indicator startAnimating];
            [indicator setCenter:_imagen.center];
            [_imagen addSubview:indicator];
            [utils downloadImageWithURL:[NSURL URLWithString:[article_json valueForKey:@"img"]] completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    [_imagen setImage:image];
                    [_imageModal setImage:image];
                    [indicator removeFromSuperview];
                }
            }];
            _autor_label.text = [article_json objectForKey:@"author"];
            _numero_shares_label.text = [[article_json objectForKey:@"shares_count"] stringValue];
            _likes_label.text = [[article_json objectForKey:@"likes_count"] stringValue];
            _date_label.text = [article_json objectForKey:@"date"];
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
            [utils controlarErrores:error];
        }
    }];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"FINISH2");
    int i=0;
    for (UIView* v in scrollView.subviews){
        i++;
    }
    NSLog(@"FINISH2 %d",i);
    
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
        if ([v tag]==50 || [v tag]==1){
            [v removeFromSuperview];
        }
    }
    _viewBuscar.hidden = TRUE;
}

- (void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
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
    int y = 182;
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
            y = y + v.frame.size.height+6;
            if([v isKindOfClass:[UIScrollView class]]){
                UIScrollView* sv = (UIScrollView*) v;
                sv.delegate = self;
            }
        }
    }
    _scroll_view.hidden = FALSE;
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
                    [_view_scroll addSubview:[constructorVistas construir_scroll_embeds:json posicion:y]];
                    y = y+160;
                }
            }
            
            for(NSDictionary* json in [[json_content objectForKey:@"content"] objectForKey:@"content_gallery_images"]){
                if([[json valueForKey:@"code"] isEqualToString:codigo_sin_corchetes]){
                    UIScrollView* s = [self construir_scroll_images:json posicion:y];
                    [_view_scroll addSubview:s];
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

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
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
                                        [_view_scroll addSubview:[constructorVistas scrollLateralItemsPeques:sellos posicion:_view_scroll.frame.size.height selector:irSellos controllerBase:self]];
                                        [self autoHeight];
                                    }
                                    NSNumber* tipo_entrevista = [[NSNumber alloc] initWithInt:[utils getKind:@"Entrevista"]];
                                    [[articles_dao sharedInstance] getRelatedItems:s.codigo_conexion kind:tipo_articulo item_id:id_a related_kind:tipo_entrevista limit:@10 page:@1 y:^(NSArray *entrevistas, NSError *error) {
                                        if (!error) {
                                            if([entrevistas count]>0){
                                                [_view_scroll addSubview:[constructorVistas construirTitulo:@"Entrevistas Relacionadas" poscion:_view_scroll.frame.size.height]];
                                                NSValue *irArticulos = [NSValue valueWithPointer:@selector(verArticulo:)];
                                                [_view_scroll addSubview:[constructorVistas scrollLateral:entrevistas posicion:_view_scroll.frame.size.height selector:irArticulos controllerBase:self]];
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
    self.altura_scroll.constant = scrollViewHeight-68;
}


- (IBAction)tweet:(id)sender {
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:[NSString stringWithFormat:@"%@%@%@%@",_titulo_label.text,@" ",@"www.bkomagazine.com/a/",[NSString stringWithFormat:@"%d",id_articulo]]];
    [self presentViewController:tweetSheet animated:YES completion:nil];
    _compartir_modal.hidden = TRUE;
}

- (IBAction)mail:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        [mailController setMailComposeDelegate:self];
        
        [mailController setSubject:_titulo_label.text];
        NSString *emailBody = [NSString stringWithFormat:@"He pensado en compartir contigo este artículo"];
        [mailController setMessageBody:emailBody isHTML:NO];
        [mailController setToRecipients:[NSArray arrayWithObjects:@"",nil]];
        [mailController.navigationBar setTintColor:[UIColor orangeColor]];
        /*dispatch_async(dispatch_get_main_queue(), ^{
            [self presentModalViewController:mailController animated:YES ];
        });*/
        
        [self presentViewController:mailController animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Necesitas tener una cuenta de mail asociada para poder compartir el artículo por mail."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    _compartir_modal.hidden = TRUE;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}



- (IBAction)facebook:(id)sender {
    SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [mySLComposerSheet setInitialText:[NSString stringWithFormat:@"%@%@%@%@",_titulo_label.text,@" ",@"www.bkomagazine.com/a/",[NSString stringWithFormat:@"%d",id_articulo]]];
    
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
    _compartir_modal.hidden = TRUE;
}
- (void)like:(id)sender {
    
    NSNumber* dos = [[NSNumber alloc] initWithInt:2];
    NSNumber* cinco = [[NSNumber alloc] initWithInt:5];
    NSNumber* id_a = [[NSNumber alloc] initWithInt:id_articulo];
    sesion *s = [sesion sharedInstance];
        [[register_dao sharedInstance] setLiked:s.codigo_conexion kind:cinco item_id:id_a like_kind:dos y:^(NSArray *artists, NSError *error){
            if (!error) {
                NSInteger likes = [_likes_label.text intValue];
                likes++;
                _likes_label.text =  [@(likes) stringValue];
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
            [self.navigationController setNavigationBarHidden:NO];
            [self.navigationController pushViewController:actualidadController animated:YES];
		} else if (index == 2) {
            //Se hace click en el label de agenda
            
            agendaIndexViewController *agendaController =
            [storyboard instantiateViewControllerWithIdentifier:@"agendaIndexViewController"];
            [self.navigationController setNavigationBarHidden:NO];
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
    ultima_busqueda_detalle = @"";
    if(_scroll_view.userInteractionEnabled){
        _scroll_view.userInteractionEnabled = FALSE;
    }
    else{
        _scroll_view.userInteractionEnabled = TRUE;
    }
    CGRect newFrame = _viewBuscar.frame;
    newFrame.origin.y = DEVICE_SIZE.height - 94;
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
    newFrame.origin.y = DEVICE_SIZE.height - 264;
    _viewBuscar.frame = newFrame;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender
{
    if(![ultima_busqueda_detalle isEqualToString:_textViewBuscar.text]){
        [self buscar];
        CGRect newFrame = _viewBuscar.frame;
        newFrame.origin.y = DEVICE_SIZE.height - 219;
        newFrame.size.height = 180;
        _viewBuscar.frame = newFrame;
    }
}

- (void) buscar
{
    sesion *s = [sesion sharedInstance];
    if(![ultima_busqueda_detalle isEqualToString:_textViewBuscar.text]){
        ultima_busqueda_detalle = _textViewBuscar.text;
        [[articles_dao sharedInstance] search:s.codigo_conexion q:_textViewBuscar.text limit:@5 page:@0 y:^(NSArray *articles, NSError *error) {
            if (!error) {
                UIScrollView* scrollViewSearch = [[UIScrollView alloc] initWithFrame:CGRectMake(0, DEVICE_SIZE.height - 54 - 114, 320, 130)];
                scrollViewSearch.tag = 50;
                [scrollViewSearch setBackgroundColor: [UIColor colorWithRed:37.0/255.0f green:37.0/255.0f blue:37.0/255.0f alpha:1]];
                int i = 0;
                NSValue *irArtistas = [NSValue valueWithPointer:@selector(verArtista:)];
                NSValue *irSitio = [NSValue valueWithPointer:@selector(verSitio:)];
                NSValue *irSello = [NSValue valueWithPointer:@selector(verSello:)];
                for (NSDictionary *JSONnoteData in articles) {
                    [constructorVistas dibujarResultadoEnPosicion:JSONnoteData en:scrollViewSearch posicion:i selectorArtista:irArtistas selectorSitio:irSitio selectorSello:irSello controllerBase:self];
                    i++;
                    numero_resultados_detalle++;
                }
                
                [self autoWidthScrollView:scrollViewSearch];
                [self.view addSubview:scrollViewSearch];
                numero_resultados_detalle = 0;
                
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

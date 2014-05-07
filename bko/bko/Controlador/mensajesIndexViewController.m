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
@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation mensajesIndexViewController

int numero_mensajes = 0;
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
    numero_mensajes = 0;
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 118;
    [self showMensajes];
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    numero_mensajes = 0;
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
            // Error processing
            NSLog(@"Error al recoger parties places: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
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
                NSLog(@"DENTRO DE UNREAD MESSAGES %@",s.messages_unread);
                NSLog(@"DENTRO DE UNREAD MESSAGES %@",countMessages);
                if (!error) {
                    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                    
                    NSDictionary* c = [countMessages objectAtIndex:0];
                    s.messages_unread = [c objectForKey:@"count"];
                }
                NSLog(@"DENTRO DE UNREAD MESSAGES %@",s.messages_unread);
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
            // Error processing
            NSLog(@"Error al recoger mensaje: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
    }];
    
}

- (IBAction)contestar:(id)sender {
    _modal_escribir.hidden = false;
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
     // Error processing
         NSLog(@"Error al contestar mensaje: %@", error);
         UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
         [theAlert show];
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


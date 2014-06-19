//
//  sorteosIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 25/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "sorteosIndexViewController.h"
#import "SWRevealViewController.h"
#import "raffle_dao.h"
#import "utils.h"
#import "sesion.h"
#import "actualidadIndexViewController.h"
#import "agendaIndexViewController.h"
#import "sorteosIndexViewController.h"
#import "sinConexionViewController.h"
#import "articles_dao.h"
#import "constructorVistas.h"
#import "fichaViewController.h"
#import "actualidadDetalleViewController.h"

@interface sorteosIndexViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *altura_scroll;

@property (weak, nonatomic) IBOutlet UIView *view_scroll;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@property (weak, nonatomic) IBOutlet UIView *viewBuscar;
@property (weak, nonatomic) IBOutlet UITextField *textViewBuscar;
@end

@implementation sorteosIndexViewController

int numero_sorteos = 0;
#define limit_paginate ((int) 6)

int numero_resultados_sorteos = 0;
NSString* ultima_busqueda_sorteos = @"";
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
    
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    //[self.revealViewController panGestureRecognizer];
    [self.revealViewController panGestureRecognizerToNul];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 180;
    self.revealViewController.delegate = self;
    
    [_viewBuscar setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.textViewBuscar.delegate=self;
    
    sesion *s = [sesion sharedInstance];
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    NSNumber *desde = [NSNumber numberWithInteger:numero_sorteos];
    NSNumber *hasta = [NSNumber numberWithInteger:limit_paginate];
    [[raffle_dao sharedInstance] getRaffles:s.codigo_conexion limit:hasta page:desde y:^(NSArray *sorteos, NSError *error) {
        if (!error) {
            if([sorteos count]>0){
                for (NSDictionary *JSONnoteData in sorteos) {
                    [self showRaffle:JSONnoteData];
                }
            }
            else{
                UILabel *no_hay_sugerencias = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 21)];
                no_hay_sugerencias.font = FONT_BEBAS(16.0f);
                no_hay_sugerencias.text = @"NO ESTÁS PARTICIPANDO EN NINGÚN SORTEO";
                no_hay_sugerencias.textAlignment = NSTextAlignmentCenter;
                no_hay_sugerencias.textColor = [UIColor colorWithRed:163.0/255.0f green:163.0/255.0f blue:163.0/255.0f alpha:1];
                [_view_scroll addSubview:no_hay_sugerencias];
            }
            [self autoHeight];
        } else {
            [utils controlarErrores:error];
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    if ([[self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2] isKindOfClass:[self class]]){
        NSMutableArray *allControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        [allControllers removeObjectAtIndex:[allControllers count] - 2];
        [self.navigationController setViewControllers:allControllers animated:NO];
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
        if ([v tag]==1 || [v tag]==50){
            [v removeFromSuperview];
        }
    }
    _viewBuscar.hidden = TRUE;
}

- (void)viewWillAppear:(BOOL)animated
{
    numero_sorteos = 0;
}

- (void) showRaffle:(NSDictionary*)json{
    //Las UIViews de cada
    int scrollViewHeight = 0;
    for (UIView* v in _view_scroll.subviews){
        scrollViewHeight += v.frame.size.height +10;
    }
    UIView *contenedorView=[[UIView alloc]initWithFrame:CGRectMake(12, scrollViewHeight + 10 , 297, 290)];
    numero_sorteos++;
    [contenedorView setBackgroundColor:[UIColor whiteColor]];
    [_view_scroll addSubview:contenedorView];
    
    UILabel *tituloSorteos = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 277, 21)];
    [contenedorView addSubview:tituloSorteos];
    tituloSorteos.text=[json objectForKey:@"title"];
    tituloSorteos.textColor=[UIColor blackColor];
    tituloSorteos.font = FONT_BEBAS(22.0f);
    tituloSorteos.textAlignment=NSTextAlignmentCenter;
    
    UILabel *subtituloSorteos = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 277, 21)];
    [contenedorView addSubview:subtituloSorteos];
    subtituloSorteos.text=[[[[[json valueForKey:@"for"] stringByAppendingString:@" @ "] stringByAppendingString:[json valueForKey:@"author"]]stringByAppendingString:@" - "] stringByAppendingString:[utils fechaConFormatoMensaje:[[json valueForKey:@"party"] valueForKey:@"date"]]];
    subtituloSorteos.textColor=[UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1];
    subtituloSorteos.font = FONT_BEBAS(22.0f);
    subtituloSorteos.textAlignment=NSTextAlignmentCenter;
    
    UIImageView *imagen_sorteo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 60, 277, 120)];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[json valueForKey:@"party"] valueForKey:@"img"]]];
    [imagen_sorteo setImage:[UIImage imageWithData:imageData]];
    [contenedorView addSubview:imagen_sorteo];
    
    if([[json objectForKey:@"winners"] count]==0){
        UILabel *listaGanadores = [[UILabel alloc] initWithFrame:CGRectMake(24, 188, 248, 21)];
        [contenedorView addSubview:listaGanadores];
        listaGanadores.text=@"la lista de ganadores se publicará en:";
        listaGanadores.textColor=[UIColor blackColor];
        listaGanadores.font = FONT_BEBAS(15.0f);
        listaGanadores.textAlignment=NSTextAlignmentCenter;

        [self showCountdown:contenedorView forDate:[utils stringToDateFormatoBarras:[json valueForKey:@"finish_date"]]];
    }
    else {
        UIImageView *imagen_has_ganado = [[UIImageView alloc] initWithFrame:CGRectMake(164, 107, 123, 73)];
        if([[json objectForKey:@"is_winner"] boolValue]){
            [imagen_has_ganado setImage:[UIImage imageNamed:@"7_icon_PREMIADO.png"]];
        }
        else{
            [imagen_has_ganado setImage:[UIImage imageNamed:@"7_icon_NO_PREMIADO.png"]];
        }
        
        [contenedorView addSubview:imagen_has_ganado];
        UILabel *ganadores = [[UILabel alloc] initWithFrame:CGRectMake(24, 188, 248, 21)];
        [contenedorView addSubview:ganadores];
        ganadores.text=@"Ganadores";
        ganadores.textColor=[UIColor grayColor];
        ganadores.font = FONT_BEBAS(15.0f);
        ganadores.textAlignment=NSTextAlignmentCenter;
        
        UILabel *separador_ganador = [[UILabel alloc] initWithFrame:CGRectMake(24, 193, 248, 21)];
        [contenedorView addSubview:separador_ganador];
        separador_ganador.text=@"_____________________________";
        separador_ganador.textColor=[UIColor blackColor];
        separador_ganador.font = FONT_BEBAS(15.0f);
        separador_ganador.textAlignment=NSTextAlignmentCenter;
        int y = 216;
        for(NSDictionary* j in [json objectForKey:@"winners"]){
            UILabel *primer_ganador = [[UILabel alloc] initWithFrame:CGRectMake(24, y-2, 248, 21)];
            [contenedorView addSubview:primer_ganador];
            primer_ganador.text=[j valueForKey:@"name"];
            primer_ganador.textColor=[UIColor blackColor];
            primer_ganador.font = FONT_BEBAS(15.0f);
            primer_ganador.textAlignment=NSTextAlignmentCenter;
            
            UILabel *separador_ganador2 = [[UILabel alloc] initWithFrame:CGRectMake(24, y+5, 248, 21)];
            [contenedorView addSubview:separador_ganador2];
            separador_ganador2.text=@"_____________________________";
            separador_ganador2.textColor=[UIColor grayColor];
            separador_ganador2.font = FONT_BEBAS(15.0f);
            separador_ganador2.textAlignment=NSTextAlignmentCenter;
            y = y +30;
        }
        
        
        
        CGRect newFrame = contenedorView.frame;
        
        newFrame.size.height = y+60;
        [contenedorView setFrame:newFrame];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(desliza_eliminar:)];
        [recognizer setDirection:UISwipeGestureRecognizerDirectionRight];
        recognizer.delegate = self;
        UIImageView *desliza_para_eliminar = [[UIImageView alloc] initWithFrame:CGRectMake(15, y+20, 268, 28)];
        [desliza_para_eliminar setImage:[UIImage imageNamed:@"7_button_DESLIZA_ELIMINAR.png"]];
        [contenedorView addSubview:desliza_para_eliminar];
        desliza_para_eliminar.userInteractionEnabled=YES;
        [desliza_para_eliminar addGestureRecognizer:recognizer];
        
    }
    
    [self autoHeight];
}

- (void) autoHeight{
    CGFloat scrollViewHeight = 0.0f;
    
    for (UIView* view in _view_scroll.subviews)
    {
        scrollViewHeight += view.frame.size.height;
    }
    self.altura_scroll.constant = scrollViewHeight + 30;
    
}


- (void) desliza_eliminar:(UISwipeGestureRecognizer *)swipe {

    sesion *s = [sesion sharedInstance];
    NSNumber *n = [[NSNumber alloc] initWithInt:swipe.view.tag];
    
    // animate the sliding of them into place
    
    [UIView transitionWithView:swipe.view 
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        //existingLabel.text = newText;
                    }
                    completion:nil];
    
    [[raffle_dao sharedInstance] deleteParticipant:s.codigo_conexion item_id:n y:^(NSArray *sorteos, NSError *error) {
        if (!error) {
            for (UIView* view in _view_scroll.subviews)
            {
                [view removeFromSuperview];
            }
            numero_sorteos = 0;
            NSNumber *desde = [NSNumber numberWithInteger:numero_sorteos];
            NSNumber *hasta = [NSNumber numberWithInteger:limit_paginate];
            [[raffle_dao sharedInstance] getRaffles:s.codigo_conexion limit:hasta page:desde y:^(NSArray *sorteos, NSError *error) {
                if (!error) {
                    for (NSDictionary *JSONnoteData in sorteos) {
                        [self showRaffle:JSONnoteData];
                    }
                    [self autoHeight];
                } else {
                    [utils controlarErrores:error];
                }
            }];
        } else {
            [utils controlarErrores:error];
        }
    }];
}

- (void)showCountdown:(UIView*)contenedor forDate: (NSDate*)fecha
{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:[NSDate date] toDate:fecha options:0];
    
    NSInteger day = [components day];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSString *digitoS1 = @"0";
    NSString *digitoS2 = @"0";
    NSString *digitoS3 = @"0";
    NSString *digitoS4 = @"0";
    NSString *digitoS5 = @"0";
    NSString *digitoS6 = @"0";
    if(day<10){
        digitoS2 = [NSString stringWithFormat:@"%d", day];
    }
    else{
        digitoS2 = [NSString stringWithFormat: @"%d", day %10];
        day = day/10;
        digitoS1 = [NSString stringWithFormat: @"%d", day %10];
    }
    if(hour<10){
        digitoS4 = [NSString stringWithFormat:@"%d", hour];
    }
    else{
        digitoS4 = [NSString stringWithFormat: @"%d", hour %10];
        hour = hour/10;
        digitoS3 = [NSString stringWithFormat: @"%d", hour %10];
    }
    if(minute<10){
        digitoS6 = [NSString stringWithFormat:@"%d", minute];
    }
    else{
        digitoS6 = [NSString stringWithFormat: @"%d", minute % 10];
        minute = minute/10;
        digitoS5 = [NSString stringWithFormat: @"%d", minute % 10];
    }
    UIView *contenedorView=[[UIView alloc]initWithFrame:CGRectMake(60, 212, 174, 70)];
    [contenedorView setBackgroundColor:[UIColor whiteColor]];
    [contenedor addSubview:contenedorView];
    
    UIImageView *imagen_countdown = [[UIImageView alloc] initWithFrame:CGRectMake(8, 11, 160, 54)];
    [imagen_countdown setImage:[UIImage imageNamed:@"countdown.png"]];
    [contenedorView addSubview:imagen_countdown];

    UILabel *digito1 = [[UILabel alloc] initWithFrame:CGRectMake(9, 29, 25, 32)];
    [contenedorView addSubview:digito1];
    digito1.text=digitoS1;
    digito1.textColor=[UIColor whiteColor];
    digito1.font = FONT_BEBAS(30.0f);
    digito1.textAlignment=NSTextAlignmentCenter;
    UILabel *digito2 = [[UILabel alloc] initWithFrame:CGRectMake(33, 29, 25, 32)];
    [contenedorView addSubview:digito2];
    digito2.text=digitoS2;
    digito2.textColor=[UIColor whiteColor];
    digito2.font = FONT_BEBAS(30.0f);
    digito2.textAlignment=NSTextAlignmentCenter;
    
    UILabel *digito3 = [[UILabel alloc] initWithFrame:CGRectMake(63, 29, 25, 32)];
    [contenedorView addSubview:digito3];
    digito3.text=digitoS3;
    digito3.textColor=[UIColor whiteColor];
    digito3.font = FONT_BEBAS(30.0f);
    digito3.textAlignment=NSTextAlignmentCenter;

    UILabel *digito4 = [[UILabel alloc] initWithFrame:CGRectMake(87, 29, 25, 32)];
    [contenedorView addSubview:digito4];
    digito4.text=digitoS4;
    digito4.textColor=[UIColor whiteColor];
    digito4.font = FONT_BEBAS(30.0f);
    digito4.textAlignment=NSTextAlignmentCenter;
    
    UILabel *digito5 = [[UILabel alloc] initWithFrame:CGRectMake(118, 29, 25, 32)];
    [contenedorView addSubview:digito5];
    digito5.text=digitoS5;
    digito5.textColor=[UIColor whiteColor];
    digito5.font = FONT_BEBAS(30.0f);
    digito5.textAlignment=NSTextAlignmentCenter;
    
    UILabel *digito6 = [[UILabel alloc] initWithFrame:CGRectMake(142, 29, 25, 32)];
    [contenedorView addSubview:digito6];
    digito6.text=digitoS6;
    digito6.textColor=[UIColor whiteColor];
    digito6.font = FONT_BEBAS(30.0f);
    digito6.textAlignment=NSTextAlignmentCenter;
    
    UIView *barra1=[[UIView alloc]initWithFrame:CGRectMake(14, 44, 15, 1)];
    [barra1 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra1];
    
    UIView *barra2=[[UIView alloc]initWithFrame:CGRectMake(37, 44, 15, 1)];
    [barra2 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra2];
    
    UIView *barra3=[[UIView alloc]initWithFrame:CGRectMake(69, 44, 15, 1)];
    [barra3 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra3];
    
    UIView *barra4=[[UIView alloc]initWithFrame:CGRectMake(93, 44, 15, 1)];
    [barra4 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra4];
    
    UIView *barra5=[[UIView alloc]initWithFrame:CGRectMake(122, 44, 15, 1)];
    [barra5 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra5];
    
    UIView *barra6=[[UIView alloc]initWithFrame:CGRectMake(147, 44, 15, 1)];
    [barra6 setBackgroundColor:[UIColor blackColor]];
    [contenedorView addSubview:barra6];
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

- (IBAction)buscar:(id)sender {
    _textViewBuscar.text = @"";
    ultima_busqueda_sorteos = @"";
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
        if ([v tag]==5){
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
    if(![ultima_busqueda_sorteos isEqualToString:_textViewBuscar.text]){
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
    if(![ultima_busqueda_sorteos isEqualToString:_textViewBuscar.text]){
        ultima_busqueda_sorteos = _textViewBuscar.text;
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
                    numero_resultados_sorteos++;
                }
                
                [self autoWidthScrollView:scrollViewSearch];
                [self.view addSubview:scrollViewSearch];
                numero_resultados_sorteos = 0;
                
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


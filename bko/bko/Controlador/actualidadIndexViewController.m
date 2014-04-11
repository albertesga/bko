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

@interface actualidadIndexViewController ()
@property (weak, nonatomic) IBOutlet UILabel *actualidad_label;
@property (weak, nonatomic) IBOutlet UILabel *titulo_image_label;
@property (weak, nonatomic) IBOutlet UIButton *menu_button;
@property (weak, nonatomic) IBOutlet UIImageView *degradado_menu;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation actualidadIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
        
        _degradado_menu.hidden = false;
    }
    else{
        _degradado_menu.hidden = true;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Cargamos las noticias
    [[articles_dao sharedInstance] fetchArticlesOnCompletion:^(NSArray *articles, NSError *error) {
        if (!error) {
            for (NSDictionary *JSONnoteData in articles) {
                
            }
        } else {
            // Error processing
        }
    }];
    
    //Las UIViews de cada
    UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(5, 5, 154, 154)];
    [paintView setBackgroundColor:[UIColor clearColor]];
    [_scrollView addSubview:paintView];
    
    UIButton *buttonActualidad = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 154, 154)];
    [buttonActualidad setBackgroundImage:[UIImage imageNamed:@"IMATGE.png"]forState:UIControlStateNormal];
    [paintView addSubview:buttonActualidad];
    [buttonActualidad addTarget:self action:@selector(detallesActualidad) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imagen_fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(3, 124, 148, 26)];
    [imagen_fondo_box setImage:[UIImage imageNamed:@"FONDO_IMAGEN.png"]];
    [paintView addSubview:imagen_fondo_box];
    
    UILabel *tituloActualidad = [[UILabel alloc] initWithFrame:CGRectMake(5, 127, 149, 21)];
    [paintView addSubview:tituloActualidad];
    tituloActualidad.text=@"hola";
    tituloActualidad.textColor=[UIColor whiteColor];
    tituloActualidad.font = FONT_BEBAS(16.0f);
    tituloActualidad.textAlignment=NSTextAlignmentCenter;
    
    
    //Menu Lateral
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 118;
    
    //Menu Radial
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    // Do any additional setup after loading the view.
    _actualidad_label.font = FONT_BEBAS(18.0f);
}

-(void)detallesActualidad
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    actualidadDetalleViewController *actualidadController =
    [storyboard instantiateViewControllerWithIdentifier:@"actualidadDetalleViewController"];
    
    [self presentViewController:actualidadController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

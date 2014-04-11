//
//  sorteosIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 25/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "sorteosIndexViewController.h"
#import "SWRevealViewController.h"

@interface sorteosIndexViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation sorteosIndexViewController

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
    
    [self.menu_lateral_button setTarget: self.revealViewController];
    [self.menu_lateral_button setAction: @selector( rightRevealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    self.revealViewController.rightViewRevealWidth = 118;
    
    //Las UIViews de cada
    UIView *contenedorView=[[UIView alloc]initWithFrame:CGRectMake(12, 64, 297, 319)];
    [contenedorView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:contenedorView];
    
    UILabel *tituloSorteos = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 277, 21)];
    [contenedorView addSubview:tituloSorteos];
    tituloSorteos.text=@"X ENTRADAS GRATIS";
    tituloSorteos.textColor=[UIColor blackColor];
    tituloSorteos.font = FONT_BEBAS(20.0f);
    tituloSorteos.textAlignment=NSTextAlignmentCenter;
    
    UILabel *subtituloSorteos = [[UILabel alloc] initWithFrame:CGRectMake(10, 31, 277, 21)];
    [contenedorView addSubview:subtituloSorteos];
    subtituloSorteos.text=@" SKRILLEX @ RAZZMATAZZ - 15 DICIEMBRE";
    subtituloSorteos.textColor=[UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1];
    subtituloSorteos.font = FONT_BEBAS(20.0f);
    subtituloSorteos.textAlignment=NSTextAlignmentCenter;
    
    UIImageView *imagen_sorteo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 60, 277, 120)];
    [contenedorView addSubview:imagen_sorteo];
    
    UIImageView *imagen_has_ganado = [[UIImageView alloc] initWithFrame:CGRectMake(164, 107, 123, 73)];
    [imagen_has_ganado setImage:[UIImage imageNamed:@"7_icon_PREMIADO.png"]];
    [contenedorView addSubview:imagen_has_ganado];
    
    UILabel *listaGanadores = [[UILabel alloc] initWithFrame:CGRectMake(24, 188, 248, 21)];
    [contenedorView addSubview:listaGanadores];
    listaGanadores.text=@"la lista de ganadores se publicará en:";
    listaGanadores.textColor=[UIColor blackColor];
    listaGanadores.font = FONT_BEBAS(15.0f);
    listaGanadores.textAlignment=NSTextAlignmentCenter;
    
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

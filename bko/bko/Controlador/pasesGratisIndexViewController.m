//
//  pasesGratisIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "pasesGratisIndexViewController.h"
#import "SWRevealViewController.h"

@interface pasesGratisIndexViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menu_lateral_button;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation pasesGratisIndexViewController


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
    
    //Las UIViews de agenda
    UIView *pasesView=[[UIView alloc]initWithFrame:CGRectMake(5, 20, 310, 314)];
    [pasesView setBackgroundColor: [UIColor whiteColor]];
    [_scrollView addSubview:pasesView];
    
    UIImageView *imagen = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 100, 100)];
    [pasesView addSubview:imagen];
    
    UIView *cuandoView=[[UIView alloc]initWithFrame:CGRectMake(5, 7, 300, 20)];
    [cuandoView setBackgroundColor:[UIColor colorWithRed:79.0/255.0f green:79.0/255.0f blue:79.0/255.0f alpha:1]];
    [pasesView addSubview:cuandoView];
    
    UILabel *nombreAgenda = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 220, 21)];
    [cuandoView addSubview:nombreAgenda];
    nombreAgenda.text=@"viernes - 22 - diciembre";
    nombreAgenda.textColor=[UIColor whiteColor];
    nombreAgenda.font = FONT_BEBAS(16.0f);
    
    UIImageView *icono_reloj = [[UIImageView alloc] initWithFrame:CGRectMake(245, 5, 11, 11)];
    [icono_reloj setImage:[UIImage imageNamed:@"5_icon_TIEMPO.png"]];
    [cuandoView addSubview:icono_reloj];
    
    UILabel *cuandoAgenda = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 43, 21)];
    [cuandoView addSubview:cuandoAgenda];
    cuandoAgenda.text=@"00:00";
    cuandoAgenda.textColor=[UIColor whiteColor];
    cuandoAgenda.font = FONT_BEBAS(16.0f);
    
    
    UITextView *descripcionAgenda = [[UITextView alloc] initWithFrame:CGRectMake(115, 28, 192, 57)];
    [descripcionAgenda setBackgroundColor:[UIColor whiteColor]];
    [pasesView addSubview:descripcionAgenda];
    descripcionAgenda.text=@"BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB BLOC CLUB";
    descripcionAgenda.textColor=[UIColor blackColor];
    descripcionAgenda.font = FONT_BEBAS(13.0f);
    
    UIButton *dondeAgenda = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 25)];
    [dondeAgenda setBackgroundImage:[UIImage imageNamed:@"9_button_CONDICIONES.png"]forState:UIControlStateNormal];
    [pasesView addSubview:dondeAgenda];
}

- (IBAction)back:(UIBarButtonItem *)sender {
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

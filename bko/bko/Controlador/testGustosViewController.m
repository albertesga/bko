//
//  testGustosViewController.m
//  bko
//
//  Created by Tito Español Gamón on 25/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "testGustosViewController.h"

@interface testGustosViewController ()
@property (weak, nonatomic) IBOutlet UILabel *presiona_label;
@property (weak, nonatomic) IBOutlet UIView *view_test;

@end

@implementation testGustosViewController

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
    _presiona_label.font = FONT_BEBAS(14.0f);
    
    UIView *paintView=[[UIView alloc]initWithFrame:CGRectMake(15, 35, 140, 140)];
    [paintView setBackgroundColor:[UIColor clearColor]];
    [_view_test addSubview:paintView];
    
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

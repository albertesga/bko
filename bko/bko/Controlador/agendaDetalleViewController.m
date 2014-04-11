//
//  agendaDetalleViewController.m
//  bko
//
//  Created by Tito Español Gamón on 25/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "agendaDetalleViewController.h"
#import "SWRevealViewController.h"

@interface agendaDetalleViewController ()
@property (weak, nonatomic) IBOutlet UILabel *agenda_label;
@property (weak, nonatomic) IBOutlet UILabel *titulo_foto_label;
@property (weak, nonatomic) IBOutlet UILabel *hora_label;
@property (weak, nonatomic) IBOutlet UILabel *localizacion_label;
@property (weak, nonatomic) IBOutlet UILabel *informacion_label;
@property (weak, nonatomic) IBOutlet UILabel *precio_entrada_label;
@property (weak, nonatomic) IBOutlet UILabel *horario_label;
@property (weak, nonatomic) IBOutlet UILabel *dresscode_label;
@property (weak, nonatomic) IBOutlet UILabel *direccion_label;
@property (weak, nonatomic) IBOutlet UIView *modal_plan_anadido;
@property (weak, nonatomic) IBOutlet UIView *modal_sorteo;
@property (weak, nonatomic) IBOutlet UIImageView *paso_1_share;
@property (weak, nonatomic) IBOutlet UIImageView *paso_2_share;
@property (weak, nonatomic) IBOutlet UIButton *share_button;
@property (weak, nonatomic) IBOutlet UILabel *local_sortea_label;
@property (weak, nonatomic) IBOutlet UILabel *que_sortea_label;
@property (weak, nonatomic) IBOutlet UILabel *para_este_evento_label;
@property (weak, nonatomic) IBOutlet UILabel *para_participar_label;

@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation agendaDetalleViewController

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
    _agenda_label.font = FONT_BEBAS(18.0f);
    _titulo_foto_label.font = FONT_BEBAS(17.0f);
    _informacion_label.font = FONT_BEBAS(15.0f);
    _hora_label.font = FONT_BEBAS(13.0f);
    _localizacion_label.font = FONT_BEBAS(13.0f);
    _precio_entrada_label.font = FONT_BEBAS(15.0f);
    _horario_label.font = FONT_BEBAS(15.0f);
    _dresscode_label.font = FONT_BEBAS(15.0f);
    _direccion_label.font = FONT_BEBAS(15.0f);
    _local_sortea_label.font = FONT_BEBAS(20.0f);
    _que_sortea_label.font = FONT_BEBAS(25.0f);
    _para_este_evento_label.font = FONT_BEBAS(20.0f);
    _para_participar_label.font = FONT_BEBAS(13.0f);
}
- (IBAction)anadir_a_mis_planes:(id)sender {
    _modal_plan_anadido.hidden = false;
}
- (IBAction)entradas_gratis:(id)sender {
    _modal_sorteo.hidden = false;
}
- (IBAction)close_share_modal:(id)sender {
    _modal_sorteo.hidden = true;
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)share_event:(id)sender {
    UIImage *img1 = [UIImage imageNamed:@"5_PASO1_DESELECCIONADO.png"];
    [_paso_1_share setImage:img1];
    _share_button.hidden=true;
    UIImage *img2 = [UIImage imageNamed:@"5_PASO2.png"];
    [_paso_2_share setImage:img2];
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

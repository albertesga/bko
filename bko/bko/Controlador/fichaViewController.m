//
//  fichaViewController.m
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "fichaViewController.h"

@interface fichaViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titulo_barra_superior;
@property (weak, nonatomic) IBOutlet UILabel *nombre_ficha;
@property (weak, nonatomic) IBOutlet UILabel *tipo_ficha_label;
@property (weak, nonatomic) IBOutlet UILabel *info_label;
@property (weak, nonatomic) IBOutlet UIButton *anadir_button;
@property (weak, nonatomic) IBOutlet UIButton *quitar_button;
@property (weak, nonatomic) IBOutlet UIView *ya_no_te_gusta_modal;
@property (weak, nonatomic) IBOutlet UIView *anadido_modal;

@end

@implementation fichaViewController

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
    _titulo_barra_superior.font = FONT_BEBAS(18.0f);
    _nombre_ficha.font = FONT_BEBAS(18.0f);
    _tipo_ficha_label.font = FONT_BEBAS(15.0f);
    _info_label.font = FONT_BEBAS(15.0f);
}
- (IBAction)anadir_mis_gustos:(id)sender {
    _anadir_button.hidden=true;
    _quitar_button.hidden=false;
    _anadido_modal.hidden=true;
    _ya_no_te_gusta_modal.hidden=false;

}
- (IBAction)quitar_mis_gustos:(id)sender {
    _anadir_button.hidden=false;
    _quitar_button.hidden=true;
    _ya_no_te_gusta_modal.hidden=true;
    _anadido_modal.hidden=false;
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

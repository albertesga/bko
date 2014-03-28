//
//  mensajesIndexViewController.m
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "mensajesIndexViewController.h"

@interface mensajesIndexViewController ()
@property (weak, nonatomic) IBOutlet UILabel *buzon_label;

@property (weak, nonatomic) IBOutlet UIView *modal_escribir;
@property (weak, nonatomic) IBOutlet UIView *modal_mensaje;
@end

@implementation mensajesIndexViewController

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
    _buzon_label.font = FONT_BEBAS(18.0f);
}

- (IBAction)escribir_mensaje:(id)sender {
    _modal_escribir.hidden = false;
}

- (IBAction)salir_escribir:(id)sender {
    _modal_escribir.hidden = true;
}
- (IBAction)ver_mensaje:(id)sender {
    _modal_mensaje.hidden = false;
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

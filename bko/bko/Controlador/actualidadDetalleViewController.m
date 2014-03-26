//
//  actualidadDetalleViewController.m
//  bko
//
//  Created by Tito Español Gamón on 21/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "actualidadDetalleViewController.h"

@interface actualidadDetalleViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titulo_label;
@property (weak, nonatomic) IBOutlet UILabel *autor_label;
@property (weak, nonatomic) IBOutlet UILabel *date_label;
@property (weak, nonatomic) IBOutlet UILabel *numero_shares_label;
@property (weak, nonatomic) IBOutlet UILabel *numero_likes_label;
@property (weak, nonatomic) IBOutlet UITextView *descripcion_evento;
@property (weak, nonatomic) IBOutlet UILabel *titulo_compartir_label;
@property (weak, nonatomic) IBOutlet UILabel *indica_como_compartir_label;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll_view;

@property (weak, nonatomic) IBOutlet UIView *compartir_modal;
@end

@implementation actualidadDetalleViewController

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
    // Do any additional setup after loading the view.
    _titulo_label.font = FONT_BEBAS(18.0f);
    _autor_label.font = FONT_BEBAS(10.0f);
    _date_label.font = FONT_BEBAS(10.0f);
    _numero_shares_label.font = FONT_BEBAS(22.0f);
    _numero_likes_label.font = FONT_BEBAS(22.0f);
    _titulo_compartir_label.font = FONT_BEBAS(18.0f);
    _indica_como_compartir_label.font = FONT_BEBAS(18.0f);
    _compartir_modal.hidden = true;
    
    //Hacemos el textview tan largo como lo sea el contenido
    
    /*CGFloat fixedWidth = _descripcion_evento.frame.size.width;
    CGSize newSize = [_descripcion_evento sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = _descripcion_evento.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    _descripcion_evento.frame = newFrame;
    _descripcion_evento.scrollEnabled = NO;*/
}

- (void)viewDidLayoutSubviews {
    [_descripcion_evento sizeToFit];
    self.scroll_view.contentSize = CGSizeMake(320, _descripcion_evento.contentSize.height+500);
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

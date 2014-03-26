//
//  registerViewController.m
//  bko
//
//  Created by Tito Español Gamón on 20/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "registerViewController.h"

@interface registerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *registrate_label;
@property (weak, nonatomic) IBOutlet UILabel *por_favor_label;
@property (weak, nonatomic) IBOutlet UILabel *para_continuar_label;

@end

@implementation registerViewController

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _registrate_label.font = FONT_BEBAS(18.0f);
    _por_favor_label.font = FONT_BEBAS(18.0f);
    _para_continuar_label.font = FONT_BEBAS(18.0f);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  problemasLoginViewController.m
//  bko
//
//  Created by Tito Español Gamón on 21/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "problemasLoginViewController.h"

@interface problemasLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *problemas_label;
@property (weak, nonatomic) IBOutlet UILabel *acceder_label;
@property (weak, nonatomic) IBOutlet UILabel *introduce_campos_label;

@end

@implementation problemasLoginViewController

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
    _problemas_label.font = FONT_BEBAS(18.0f);
    _acceder_label.font = FONT_BEBAS(18.0f);
    _introduce_campos_label.font = FONT_BEBAS(18.0f);
    // Do any additional setup after loading the view.
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

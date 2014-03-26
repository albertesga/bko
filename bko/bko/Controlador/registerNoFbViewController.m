//
//  registerNoFbViewController.m
//  bko
//
//  Created by Tito Español Gamón on 21/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "registerNoFbViewController.h"

@interface registerNoFbViewController ()
@property (weak, nonatomic) IBOutlet UILabel *por_favor;
@property (weak, nonatomic) IBOutlet UILabel *si_no_facebook;
@property (weak, nonatomic) IBOutlet UILabel *completa_los_campos;

@end

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

@implementation registerNoFbViewController

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
    _si_no_facebook.font = FONT_BEBAS(18.0f);
    _por_favor.font = FONT_BEBAS(18.0f);
    _completa_los_campos.font = FONT_BEBAS(18.0f);
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

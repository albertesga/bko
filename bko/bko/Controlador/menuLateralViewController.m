//
//  menuLateralViewController.m
//  bko
//
//  Created by Tito Español Gamón on 26/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "menuLateralViewController.h"
#import "sorteosIndexViewController.h"
#import "SWRevealViewController.h"
#import "menuController.h"
#import "sesion.h"

@interface menuLateralViewController ()

@end


@implementation menuLateralViewController

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    NSLog(@"ESTAMOS");
    // configure the destination view controller:
    
    // configure the segue.
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] )
    {
        SWRevealViewControllerSegue* rvcs = (SWRevealViewControllerSegue*) segue;
        
        SWRevealViewController* rvc = self.revealViewController;
        NSAssert( rvc != nil, @"Error: Debe ser un revealViewController" );
        
        NSAssert( [rvc.frontViewController isKindOfClass: [UINavigationController class]], @"oops!  Para Este Segue necesitamos que sea un NavigationController en el FronViewController" );
        
        rvcs.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
        {
            //Cambio es el custom segue que salen del menu lateral
            //Cogemos el NavigationController y hacemos un PUSH
            //El código original creaba un nuevo Navigation Controller por lo que se perdía la cola de UIViewControllers para hacer PUSH/POP
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController pushViewController:dvc animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
    }
}


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
    _numero_mensajes.font = FONT_BEBAS(10.0f);
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    sesion *s = [sesion sharedInstance];
    if(s.messages_unread.intValue!=0 && s.messages_unread !=nil ){
        self.numero_mensajes.text = [s.messages_unread stringValue];
        self.numero_mensajes.hidden = FALSE;
        self.notificacion_view.hidden = FALSE;
    }
    else{
        self.numero_mensajes.hidden = TRUE;
        self.notificacion_view.hidden = TRUE;
    }
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

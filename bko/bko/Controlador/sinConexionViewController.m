//
//  sinConexionViewController.m
//  bko
//
//  Created by Tito Español Gamón on 01/06/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "sinConexionViewController.h"
#import "utils.h"
#import "register_dao.h"
#import "sesion.h"
#import "message_dao.h"
#import "SWRevealViewController.h"

@interface sinConexionViewController ()

@end

@implementation sinConexionViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refrescar:(id)sender {
    
    if(![utils connected]){
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
        sinConexionViewController *sinConexion =
        [storyboard instantiateViewControllerWithIdentifier:@"sinConexionViewController"];
        [self presentViewController:sinConexion animated:NO completion:nil];
    }
    if([utils userAllowedToUseApp]){
        NSDictionary* user_pass = [utils retriveUsernamePassword];
        [[register_dao sharedInstance] login:[user_pass objectForKey:@"username"] password:[user_pass objectForKey:@"password"] token:nil y:^(NSArray *connection, NSError *error) {
            if (!error) {
                sesion *s = [sesion sharedInstance];
                NSDictionary* con = [connection objectAtIndex:0];
                s.codigo_conexion = [[con objectForKey:@"connection"] objectForKey:@"code"];
                
                [[message_dao sharedInstance] getUnreadMessagesCount:s.codigo_conexion y:^(NSArray *countMessages, NSError *error) {
                    if (!error) {
                        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                        [f setNumberStyle:NSNumberFormatterDecimalStyle];
                        
                        NSDictionary* c = [countMessages objectAtIndex:0];
                        s.messages_unread = [c objectForKey:@"count"];
                        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
                        SWRevealViewController *actualidad =
                        [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
                        [self presentViewController:actualidad animated:NO completion:nil];
                    } else {
                        [utils controlarErrores:error];
                    }
                }];
                
                
            } else {
                // Error processing
                NSLog(@"Error en la llamada del login: %@", error);
                if([[error localizedDescription] isEqualToString:@"The Internet connection appears to be offline."]){
                    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
                    sinConexionViewController *sinConexion =
                    [storyboard instantiateViewControllerWithIdentifier:@"sinConexionViewController"];
                    [self presentViewController:sinConexion animated:NO completion:nil];
                    return;
                }
                else{
                    [utils controlarErrores:error];
                }
            }
        }];
    }
    
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

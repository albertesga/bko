//
//  registerAppDelegate.m
//  bko
//
//  Created by Tito Español Gamón on 20/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//
#import <FacebookSDK/FacebookSDK.h>
#import "registerAppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "utils.h"
#import "revealViewController.h"
#import "registerViewController.h"
#import "register_dao.h"

@implementation registerAppDelegate

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Cambiamos el aspecto del topbar para que siempre sea igual
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"BebasNeue" size:21.0], NSFontAttributeName, nil]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    
    //Parámetro que permite dejar de controlar el indicador de la conexión
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    //Controlamos, si no tiene acceso lo llevamos al registro, si tiene le hacemos login automáticamente y le llevamos a la página de actualidad
    /*UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
    if(![utils userAllowedToUseApp]){
        registerViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"registerViewController"];
        self.window.rootViewController = viewController;
    }else{
        [[register_dao sharedInstance] login:[[utils retriveUsernamePassword] objectForKey:@"username"] password:[[utils retriveUsernamePassword] objectForKey:@"password"] y:^(NSArray *connection, NSError *error) {
            if (!error) {
                //Debemos hacer likes automáticos en el registro a través de facebook
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
                revealViewController *actualidad =
                [storyboard instantiateViewControllerWithIdentifier:@"revealViewController"];
                self.window.rootViewController = actualidad;
            } else {
                // Error processing
                NSLog(@"Error en la llamada del registro: %@", error);
            }
        }];
    }*/
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end

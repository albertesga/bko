//
//  registerViewController.m
//  bko
//
//  Created by Tito Español Gamón on 20/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "registerViewController.h"
#import "backgroundAnimate.h"
#import "actualidadIndexViewController.h"
#import "register_dao.h"
#import "Artists.h"

@interface registerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *registrate_label;
@property (weak, nonatomic) IBOutlet UILabel *por_favor_label;
@property (weak, nonatomic) IBOutlet UILabel *para_continuar_label;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIView *viewCentral;
@property (strong, nonatomic) NSString* first_name;
@property (strong, nonatomic) NSString* last_name;
@property (strong, nonatomic) NSString* birthday;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) NSMutableArray *likes;
@property (strong, nonatomic) NSMutableArray *wall;
@end

@implementation registerViewController

id<FBGraphUser> cachedUser;
//bool array_lleno=false;

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _registrate_label.font = FONT_BEBAS(18.0f);
    _por_favor_label.font = FONT_BEBAS(18.0f);
    _para_continuar_label.font = FONT_BEBAS(18.0f);
    
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_likes"]];
    
    
    loginView.frame = CGRectMake(55, 277, 210, 36);
    
    for (id loginObject in loginView.subviews)
    {
        if ([loginObject isKindOfClass:[UIButton class]])
        {
            UIButton * loginButton =  loginObject;
            UIImage *loginImage = [UIImage imageNamed:@"14_2_Button_FACEBOOK.png"];
            loginButton.alpha = 0.7;
            [loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
            [loginButton setBackgroundImage:nil forState:UIControlStateSelected];
            [loginButton setBackgroundImage:nil forState:UIControlStateHighlighted];
            [loginButton sizeToFit];
        }
        if ([loginObject isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  loginObject;
            loginLabel.text = @"";
            loginLabel.frame = CGRectMake(0, 0, 0, 0);
        }
    }
    loginView.delegate = self;
    [self.view addSubview:loginView];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    //Ponemos este if es porque esta funcion se llama dos veces, y solo nos interesa coger los datos y pasar al siguiente controlador cuando user tiene la información
    if (![self isUser:cachedUser equalToUser:user]) {
        cachedUser = user;
        _likes = [[NSMutableArray alloc]init];
        _wall = [[NSMutableArray alloc]init];
        
        //OJO!! Tenemos que quitar los limit en producción
        [self getFBLikes:[NSString stringWithFormat:@"/%@/music?fields=id", user.id]];
        //[self getFBWall:[NSString stringWithFormat:@"/%@/posts?type=status,photo", user.id]];
        
        
        _first_name = user.first_name;
        _last_name = user.last_name;
        _birthday = user.birthday;
        _email = [user objectForKey:@"email"];
        _location = [NSString stringWithFormat:@"Location: %@\n\n",user.location[@"name"]];
    }
}

-(void)getFBLikes:(NSString*)url {
    [FBRequestConnection startWithGraphPath:url
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  [self parseFBResultLikes:result];
                                  
                                  NSDictionary *paging = [result objectForKey:@"paging"];
                                  NSString *next = [paging objectForKey:@"next"];
                                  
                                  [self getFBLikes:[next substringFromIndex:27]];
                                  
                              } else {
                                  NSLog(@"Error recogiendo likes del Facebook: %@", [error localizedDescription]);
                              }
                          }];
}

-(void)parseFBResultLikes:(id)result {
    NSArray *data = [result objectForKey:@"data"];
    for(NSDictionary *like in data){
        [_likes addObject: [like objectForKey:@"id"]];
    }
    NSDictionary *paging = [result objectForKey:@"paging"];
    NSString *next = [paging objectForKey:@"next"];
    //Si no hay next es que hemos llegado al final y no se debe paginar más
    if(next==NULL){
            [self registro];
    }
    
}


-(void)registro {
    if(![utils userAllowedToUseApp]){
    //Primero hacemos el registro
    [[register_dao sharedInstance] addUser:_email name:_first_name surname:_last_name birthdate:_birthday y:^(NSArray *password, NSError *error) {
     if (!error) {
         
         [utils allowUserToUseApp:_email password:[password objectAtIndex:0]];
         
         //Hacemos login para tener el código de conexión
         [[register_dao sharedInstance] login:_email password:[password objectAtIndex:0] y:^(NSArray *connection, NSError *error) {
             if (!error) {
                 //Debemos hacer likes automáticos en el registro a través de facebook
                 [[register_dao sharedInstance] getAllFacebookArtists:^(NSArray *artists, NSError *error) {
                     if (!error) {
                         //Debemos hacer likes automáticos en el registro a través de facebook
                         for (Artists *artist in artists) {
                             for(id id_artista_fb in _likes){
                                 //Si hay un like del
                                 if(id_artista_fb==artist.card_id){
                                     [self setLike:[connection objectAtIndex:0] kind:@1 item_id:artist.card_id];
                                 }
                             }
                         }
                         UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
                         actualidadIndexViewController *actualidad =
                         [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
                         [self presentViewController:actualidad animated:NO completion:nil];
                     } else {
                         // Error processing
                     }
                 }];
             } else {
                 // Error processing
                 NSLog(@"Error en la llamada del registro: %@", error);
             }
         }];
     
     
     } else {
     // Error processing
     NSLog(@"Error en la llamada del registro: %@", error);
     }
     }];
    }
}

- (void) setLike:(NSString *)connection_code kind:(NSNumber *)kind item_id:(NSNumber *)item_id{
    [[register_dao sharedInstance] getAllFacebookArtists:^(NSArray *artists, NSError *error) {
        if (!error) {
            //Debemos hacer likes automáticos en el registro a través de facebook
            
        } else {
            // Si hay un error lo obviamos...
        }
    }];
}

- (BOOL)isUser:(id<FBGraphUser>)firstUser equalToUser:(id<FBGraphUser>)secondUser {
    return
    [firstUser.id isEqual:secondUser.id] &&
    [firstUser.name isEqual:secondUser.name] &&
    [firstUser.first_name isEqual:secondUser.first_name] &&
    [firstUser.last_name isEqual:secondUser.last_name];
}

- (void) loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"Empezamos Facebook Connect");
}


// Controlamos los posibles errores que nos puede dar la llamada a Facebook Connect
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;

    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];

    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Sesion Error";
        alertMessage = @"Tu actual sesión ya no es válida. Por favor, logueate otra vez.";

    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"Usuario canceló login");
    } else {
        alertTitle  = @"Algo fue mal";
        alertMessage = @"Pruébalo otra vez dentro de unos minutos";
        NSLog(@"Unexpected error:%@", error);
    }
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [FBLoginView class];
    
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

- (void)viewDidAppear:(BOOL)animated {
    
    //Llamamos al Singleton backgroundAnimate y ejecutamos la funcion que anima el background
    backgroundAnimate *background = [backgroundAnimate sharedInstance];
    [background animateBackground:self.backgroundImageView];
    
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)note {
    backgroundAnimate *background = [backgroundAnimate sharedInstance];
    [background animateBackground:self.backgroundImageView];
    [background applyCloudLayerAnimation];
}

/*
 -(void)getFBWall:(NSString*)url {
 [FBRequestConnection startWithGraphPath:url
 completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
 if (!error) {
 
 [self parseFBResultWall:result];
 
 NSDictionary *paging = [result objectForKey:@"paging"];
 
 NSString *next = [paging objectForKey:@"next"];
 
 [self getFBWall:[next substringFromIndex:27]];
 
 } else {
 NSLog(@"Error recogiendo poost del Facebook: %@", [error localizedDescription]);
 }
 }];
 }
 
 
 -(void)parseFBResultWall:(id)result {
 NSArray *data = [result objectForKey:@"data"];
 
 for(NSDictionary *post in data){
 if([post valueForKey:@"message"]!=nil){
 [_wall addObject: [post objectForKey:@"message"]];
 }
 else if([post valueForKey:@"description"]!=nil){
 [_wall addObject: [post objectForKey:@"description"]];
 }
 }
 NSDictionary *paging = [result objectForKey:@"paging"];
 NSString *next = [paging objectForKey:@"next"];
 //Debemos hacer el registro en caso de que tanto el array de posts como el de likes esté lleno.
 //Si array_lleno está a false es que el de likes aun no se ha llenado, así que lo ponemos a true y esperamos
 //que se registre cuando se acabe de llenar el array de likes
 if(next==NULL){
 if(array_lleno){
 [self registro];
 }
 else{
 array_lleno = true;
 }
 }
 
 }*/

@end

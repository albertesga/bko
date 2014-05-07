//
//  testGustosViewController.m
//  bko
//
//  Created by Tito Español Gamón on 25/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "testGustosViewController.h"
#import "register_dao.h"
#import "sesion.h"
#import "Artists.h"
#import "backgroundAnimate.h"
#import "utils.h"

@interface testGustosViewController ()
@property (weak, nonatomic) IBOutlet UILabel *presiona_label;
@property (weak, nonatomic) IBOutlet UIView *view_test;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *artistes;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *image_finalizado;
@property (weak, nonatomic) IBOutlet UIImageView *image_logo;
@property (weak, nonatomic) IBOutlet UIButton *button_finalizado;

@end

@implementation testGustosViewController

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]
int accion_usuario = 0;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)like:(id)sender {
    //Cogemos el índice del array porque tendremos que cambiar el label
    UIButton *b = (UIButton*)sender;
    
    b.superview.transform =CGAffineTransformMakeScale(1,0);
    [UIView animateWithDuration:0.8 animations:^{
        b.superview.alpha = 1.0;
        b.superview.transform =CGAffineTransformMakeScale(0.0,0.0);
    }];
    accion_usuario++;
    [self.artistes indexOfObject:b.superview];
    NSNumber *id_artist = [NSNumber numberWithInteger:b.superview.tag];
    sesion *s = [sesion sharedInstance];
    NSNumber* zero = [[NSNumber alloc] initWithInt:0];
    [[register_dao sharedInstance] setLiked:s.codigo_conexion kind:zero item_id:id_artist like_kind:zero y:^(NSArray *artists, NSError *error){
        if (!error) {
            [[register_dao sharedInstance] getPossibleArtistsLiked:s.codigo_conexion limit:@4 page:@1 y:^(NSArray *artists_json, NSError *error) {
                if (!error) {
                    if([artists_json count]==0 || accion_usuario > 5){
                        [self finalizar];
                    }
                    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                    /*for (NSDictionary* artist in artists_json) {
                        UIView *view = b.superview;
                        NSNumber *id_artist =[f numberFromString:[artist objectForKey:@"id"]];
                        [view setTag:[id_artist intValue]];
                        for(UIView *aux in view.subviews){
                            if([aux isKindOfClass:[UILabel class]]){
                                UILabel *label_artist = (UILabel*) aux;
                                label_artist.text = [artist objectForKey:@"name"];
                            }
                            if([aux isKindOfClass:[UIButton class]]){
                                UIButton *image = (UIButton*) aux;
                                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[artist objectForKey:@"list_img"]]];
                                [image setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
                            }
                        }
                        b.superview.transform =CGAffineTransformMakeScale(0,0);
                        [UIView animateWithDuration:0.8 animations:^{
                            b.superview.alpha = 1.0;
                            b.superview.transform =CGAffineTransformMakeScale(1.0,1.0);
                        }];
                    }*/
                    NSLog(@"ENTRO %@",artists_json);
                    int i=0;
                    for (UIView* artist_view in _artistes) {
                        if([artists_json count] > i){
                            NSDictionary* artist = [artists_json objectAtIndex:i];
                            i++;
                            
                                NSNumber *id_artist = [f numberFromString:[artist objectForKey:@"id"]];
                                [artist_view setTag:[id_artist intValue]];
                            
                                for(UIView *aux in artist_view.subviews){
                                    if([aux isKindOfClass:[UILabel class]]){
                                        UILabel *label_artist = (UILabel*) aux;
                                        label_artist.text = [artist objectForKey:@"name"];
                                    }
                                    if([aux isKindOfClass:[UIButton class]]){
                                        UIButton *image = (UIButton*) aux;
                                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[artist objectForKey:@"list_img"]]];
                                        [image setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
                                    }
                                }
                                artist_view.transform =CGAffineTransformMakeScale(0,0);
                                [UIView animateWithDuration:0.8 animations:^{
                                    artist_view.alpha = 1.0;
                                    artist_view.transform =CGAffineTransformMakeScale(1.0,1.0);
                                }];
                                [artist_view sendSubviewToBack:[artist_view.subviews lastObject]];
                        }
                        else{
                            artist_view.hidden= YES;
                        }
                    }
                    
                } else {
                    // Error al recoger el artista
                    NSLog(@"Error en la recogida de artistas: %@", error);
                    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                       message:[error localizedDescription]
                                                                      delegate:self
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                    [theAlert show];
                }
            }];

        } else {
            // Error hacer el like
            NSLog(@"Error al hacer like: %@", error);
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:[error localizedDescription]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
        }
    }];
}

- (IBAction)no_me_gusta_ninguno:(id)sender {
    accion_usuario++;
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    for (UIView* artist_view in _artistes) {
        if(artist_view.alpha!=0.0){
        NSNumber *id_artist = [NSNumber numberWithInteger:artist_view.tag];
        sesion *s = [sesion sharedInstance];
        NSNumber* zero = [[NSNumber alloc] initWithInt:0];
        artist_view.transform =CGAffineTransformMakeScale(1,0);
        [UIView animateWithDuration:0.8 animations:^{
            artist_view.alpha = 0.0;
            artist_view.transform =CGAffineTransformMakeScale(0.0,0.0);
        }];
        [[register_dao sharedInstance] setUnliked:s.codigo_conexion kind:zero item_id:id_artist like_kind:zero y:^(NSArray *artists, NSError *error){
            if (!error) {
                [[register_dao sharedInstance] getPossibleArtistsLiked:s.codigo_conexion limit:@4 page:@1 y:^(NSArray *artists, NSError *error) {
                    if (!error) {
                        if([artists count]==0 || accion_usuario > 5){
                            [self finalizar];
                        }
                        for (NSDictionary* artist in artists) {
                            
                            NSNumber *id_artist = [f numberFromString:[artist objectForKey:@"id"]];
                            [artist_view setTag:[id_artist intValue]];
                            
                            for(UIView *aux in artist_view.subviews){
                                if([aux isKindOfClass:[UILabel class]]){
                                    UILabel *label_artist = (UILabel*) aux;
                                    label_artist.text = [artist objectForKey:@"name"];
                                }
                                if([aux isKindOfClass:[UIButton class]]){
                                    UIButton *image = (UIButton*) aux;
                                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[artist objectForKey:@"list_img"]]];
                                    [image setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
                                }
                            }
                            artist_view.transform =CGAffineTransformMakeScale(0,0);
                            [UIView animateWithDuration:0.8 animations:^{
                                artist_view.alpha = 1.0;
                                artist_view.transform =CGAffineTransformMakeScale(1.0,1.0);
                            }];
                            [artist_view sendSubviewToBack:[artist_view.subviews lastObject]];
                        }
                    } else {
                        // Error al recoger el artista
                        NSLog(@"Error al recoger artistas: %@", error);
                        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                           message:[error localizedDescription]
                                                                          delegate:self
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                        [theAlert show];
                    }
                }];
                
            } else {
                // Error hacer el unlike
                NSLog(@"Error al hacer unlike: %@", error);
                UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                   message:[error localizedDescription]
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                [theAlert show];
            }
        }];
        }
    }
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    sesion *s = [sesion sharedInstance];
    for (UIView* artist_view in _artistes) {
        artist_view.alpha = 0.0;
    }
                
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                [[register_dao sharedInstance] getPossibleArtistsLiked:s.codigo_conexion limit:@4 page:@1 y:^(NSArray *artists, NSError *error) {
                    if (!error) {
                        int i =0;
                        for (NSDictionary* artist in artists) {
                            UIView *view = [_artistes objectAtIndex:i];
                            NSNumber *id_artist =[f numberFromString:[artist objectForKey:@"id"]];
                            [view setTag:[id_artist intValue]];
                            for(UIView *aux in view.subviews){
                                if([aux isKindOfClass:[UILabel class]]){
                                    UILabel *label_artist = (UILabel*) aux;
                                    label_artist.text = [artist objectForKey:@"name"];
                                    label_artist.font = FONT_BEBAS(17.0f);
                                }
                                if([aux isKindOfClass:[UIButton class]]){
                                    UIButton *image = (UIButton*) aux;
                                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[artist objectForKey:@"list_img"]]];
                                    [image setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
                                }
                            }
                            view.transform =CGAffineTransformMakeScale(0,0);
                            [UIView animateWithDuration:0.8 animations:^{
                                view.alpha = 1.0;
                                view.transform =CGAffineTransformMakeScale(1.0,1.0);
                            }];
                            [view sendSubviewToBack:[view.subviews lastObject]];
                            i++;
                        }
                    } else {
                        // Error processing
                        NSLog(@"Error recogiendo artistas: %@", error);
                        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                           message:[error localizedDescription]
                                                                          delegate:self
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                        [theAlert show];
                    }
                }];
    
    
    _presiona_label.font = FONT_BEBAS(14.0f);
    
    
}

-(void)finalizar{
    _image_finalizado.hidden = FALSE;
    _image_logo.hidden = TRUE;
    _view_test.hidden = TRUE;
    _button_finalizado.hidden = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

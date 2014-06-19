//
//  constructorVistas.h
//  bko
//
//  Created by Tito Español Gamón on 29/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface constructorVistas : NSObject

+ (UIWebView *) embed:(NSDictionary *)embed posicion:(int)posicion unElemento:(bool) unElemento;
+ (void) image:(NSDictionary *)image unElemento:(bool)unElemento en:(UIScrollView*)scrollView;
+ (UIView *) construirTitulo:(NSString *)titulo poscion:(int)poscion;
+ (UIView *) construirTituloOscuro:(NSString *)titulo poscion:(int)poscion;
+ (UIScrollView *) scrollLateral:(NSArray *)items posicion:(int)posicion selector:(NSValue*) selector controllerBase:(UIViewController*) controller;
+ (UIScrollView *) scrollLateralItemsPeques:(NSArray *)items posicion:(int)posicion selector:(NSValue*) selector controllerBase:(UIViewController*) controller;
+ (UIScrollView*) construir_scroll_images:(NSDictionary*) json posicion:(int) posicion;
+ (UIScrollView*) construir_scroll_embeds:(NSDictionary*) json posicion:(int) posicion;
+ (void) dibujarResultadoEnPosicion:(NSDictionary *)json en:(UIScrollView*)scrollViewSearch posicion:(int)i selectorArtista:(NSValue*) selectorArtista selectorSitio:(NSValue*) selectorSitio
                     selectorSello:(NSValue*) selectorSello controllerBase:(UIViewController*) controller;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;
@end

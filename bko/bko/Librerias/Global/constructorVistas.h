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
+ (UIView *) image:(NSDictionary *)embed posicion:(int)posicion unElemento:(bool) unElemento;
+ (UIView *) construirTitulo:(NSString *)titulo poscion:(int)poscion;
+ (UIView *) construirTituloOscuro:(NSString *)titulo poscion:(int)poscion;
+ (UIScrollView *) scrollLateral:(NSArray *)items posicion:(int)posicion selector:(NSValue*) selector controllerBase:(UIViewController*) controller;
+ (UIScrollView *) scrollLateralItemsPeques:(NSArray *)items posicion:(int)posicion selector:(NSValue*) selector controllerBase:(UIViewController*) controller;
+ (UIScrollView*) construir_scroll_images:(NSDictionary*) json posicion:(int) posicion;
+ (UIScrollView*) construir_scroll_embeds:(NSDictionary*) json posicion:(int) posicion;
@end

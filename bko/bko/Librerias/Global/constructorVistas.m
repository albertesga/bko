//
//  constructorVistas.m
//  bko
//
//  Created by Tito Español Gamón on 29/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "constructorVistas.h"
#import "fichaViewController.h"
#import "actualidadDetalleViewController.h"

@implementation constructorVistas

#define FONT_BEBAS(s) [UIFont fontWithName:@"BebasNeue" size:s]

+ (UIWebView *) embed:(NSDictionary *)embed posicion:(int)posicion unElemento:(bool) unElemento{
    NSString *html = [embed objectForKey:@"content"];
    int anchura_embed = 220;
    int altura_embed = 150;
    if(unElemento){
        anchura_embed = 270;
        altura_embed = 184;
        posicion = 30;
    }
    NSString *word = @"soundcloud";
    if ([html rangeOfString:word].location != NSNotFound) {
        anchura_embed = 150;
        if(unElemento){
            anchura_embed = 200;
            altura_embed = 200;
            posicion = 60;
        }
    }

    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(.*width=\").*?(\".*?height=\").*?(\".*)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    html = [regex stringByReplacingMatchesInString:html
                                           options:0
                                             range:NSMakeRange(0, [html length])
                                      withTemplate:@"$1100%%$290%%$3"];
    html = [html stringByReplacingOccurrencesOfString:@"'mozallowfullscreen" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"'allowfullscreen" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"'webkitallowfullscreen" withString:@""];
    UIWebView *videoWebView = [[UIWebView alloc] initWithFrame:CGRectMake(posicion, 0, anchura_embed, 150)];
    [videoWebView setBackgroundColor:[UIColor colorWithRed: 233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0]];
    NSURL *url = [[NSURL alloc] initWithString:@"http:"];
    [videoWebView loadHTMLString:html baseURL:url];
    videoWebView.scrollView.scrollEnabled = NO;
    if ([html rangeOfString:word].location == NSNotFound) {
        videoWebView.scalesPageToFit = YES;
    }
    return videoWebView;
}

+ (UIView *) image:(NSDictionary *)image posicion:(int)posicion unElemento:(bool) unElemento{
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[image objectForKey:@"image"]]];
    UIImage* i = [UIImage imageWithData:imageData];
    int anchura_embed = 240;
    int altura_embed = 160;
    if(unElemento){
        anchura_embed = 270;
        altura_embed = 184;
        posicion = 30;
    }
    UIImage* new_image = [self imageWithImage:i
                             scaledToMaxWidth:anchura_embed
                                    maxHeight:altura_embed];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(posicion, 0, new_image.size.width, new_image.size.height)];
    [imageView setBackgroundColor:[UIColor colorWithRed: 233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0]];
    [imageView setImage:new_image];
    imageView.userInteractionEnabled = YES;
    
    return imageView;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [self imageWithImage:image scaledToSize:newSize];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIView *) construirTitulo:(NSString *)titulo poscion:(int)poscion{
    UIView *view_titulo = [[UITextView alloc] initWithFrame:CGRectMake(0, poscion, 320, 30)];
    [view_titulo setBackgroundColor:[UIColor colorWithRed:214/255.0f green:214/255.0f blue:214/255.0f alpha:1.0]];
    [view_titulo setUserInteractionEnabled:NO];
    UILabel *texto = [[UILabel alloc] initWithFrame:CGRectMake(7, 5, 310, 20)];
    texto.font = FONT_BEBAS(17.0f);
    texto.text = titulo;
    texto.textColor = [UIColor colorWithRed:66/255.0f green:66/255.0f blue:66/255.0f alpha:1.0];
    [view_titulo addSubview:texto];
    return view_titulo;
}

+ (UIView *) construirTituloOscuro:(NSString *)titulo poscion:(int)poscion{
    UIView *view_titulo = [[UITextView alloc] initWithFrame:CGRectMake(0, poscion, 320, 30)];
    [view_titulo setBackgroundColor:[UIColor colorWithRed:190/255.0f green:190/255.0f blue:190/255.0f alpha:1.0]];
    [view_titulo setUserInteractionEnabled:NO];
    UILabel *texto = [[UILabel alloc] initWithFrame:CGRectMake(7, 5, 310, 20)];
    texto.font = FONT_BEBAS(17.0f);
    texto.text = titulo;
    texto.textColor = [UIColor colorWithRed:66/255.0f green:66/255.0f blue:66/255.0f alpha:1.0];
    [view_titulo addSubview:texto];
    return view_titulo;
}

+ (UIScrollView *) scrollLateral:(NSArray *)items posicion:(int)posicion selector:(NSValue*) selector controllerBase:(UIViewController*) controller{
    UIScrollView* scrollLateral = [[UIScrollView alloc] initWithFrame:CGRectMake(0, posicion + 30, 320, 110)];
    scrollLateral.alwaysBounceVertical = false;
    [scrollLateral setBackgroundColor:[UIColor colorWithRed: 233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0]];
    for (NSDictionary *item in items) {
        
        UIView *itemView=[[UIView alloc]initWithFrame:CGRectMake(scrollLateral.contentSize.width + 2, 5, 100, 100)];
        [itemView setBackgroundColor:[UIColor clearColor]];
        [scrollLateral addSubview:itemView];
        
        UIButton *buttonArtista = [[UIButton alloc] initWithFrame:CGRectMake(2, 2, 96, 96)];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[item valueForKey:@"list_img"]]];
        [buttonArtista setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        [itemView addSubview:buttonArtista];
        
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *id_artist =[f numberFromString:[item objectForKey:@"item_related_id"]];
        [buttonArtista setTag:[id_artist intValue]];
        [buttonArtista addTarget:controller action:[selector pointerValue] forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [fondo_box setImage:[UIImage imageNamed:@"IMATGE.png"]];
        [itemView addSubview:fondo_box];
        [itemView sendSubviewToBack:fondo_box];
        
        UIImageView *imagen_fondo_box = [[UIImageView alloc] initWithFrame:CGRectMake(2, 78, 96, 20)];
        [imagen_fondo_box setImage:[UIImage imageNamed:@"FONDO_IMAGEN.png"]];
        [itemView addSubview:imagen_fondo_box];
        
        UILabel *tituloActualidad = [[UILabel alloc] initWithFrame:CGRectMake(2, 80, 96, 18)];
        [itemView addSubview:tituloActualidad];
        tituloActualidad.text=[item valueForKey:@"list_title"];
        tituloActualidad.textColor=[UIColor whiteColor];
        tituloActualidad.font = FONT_BEBAS(16.0f);
        tituloActualidad.textAlignment=NSTextAlignmentCenter;
        
        CGFloat scrollViewWidth = 0.0f;
        for (UIWebView* view in scrollLateral.subviews)
        {
            scrollViewWidth += view.frame.size.width;
        }
        [scrollLateral setContentSize:(CGSizeMake(scrollViewWidth, 110))];
    }
    return scrollLateral;
}

+ (UIScrollView *) scrollLateralItemsPeques:(NSArray *)items posicion:(int)posicion selector:(NSValue*) selector controllerBase:(UIViewController*) controller{
    UIScrollView* scrollLateral = [[UIScrollView alloc] initWithFrame:CGRectMake(0, posicion + 30, 320, 85)];
    scrollLateral.alwaysBounceVertical = false;
    [scrollLateral setBackgroundColor:[UIColor colorWithRed: 233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0]];
    for (NSDictionary *item in items) {
        
        UIView *itemView=[[UIView alloc]initWithFrame:CGRectMake(scrollLateral.contentSize.width + 2, 5, 60, 60)];
        [itemView setBackgroundColor:[UIColor clearColor]];
        [scrollLateral addSubview:itemView];
        
        UIButton *buttonArtista = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[item valueForKey:@"list_img"]]];
        [buttonArtista setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        [itemView addSubview:buttonArtista];
        
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *id_artist =[f numberFromString:[item objectForKey:@"item_related_id"]];
        [buttonArtista setTag:[id_artist intValue]];
        [buttonArtista addTarget:controller action:[selector pointerValue] forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *tituloActualidad = [[UILabel alloc] initWithFrame:CGRectMake(0, 62, 70, 15)];
        [itemView addSubview:tituloActualidad];
        tituloActualidad.text=[item valueForKey:@"list_title"];
        tituloActualidad.textColor=[UIColor blackColor];
        tituloActualidad.font = FONT_BEBAS(13.0f);
        tituloActualidad.textAlignment=NSTextAlignmentCenter;
        
        CGFloat scrollViewWidth = 0.0f;
        for (UIWebView* view in scrollLateral.subviews)
        {
            scrollViewWidth += view.frame.size.width;
        }
        [scrollLateral setContentSize:(CGSizeMake(scrollViewWidth, 85))];
    }
    return scrollLateral;
}

+ (UIScrollView*)construir_scroll_embeds:(NSDictionary*) json posicion:(int) posicion{
    UIScrollView* scrollLateral = [[UIScrollView alloc] initWithFrame:CGRectMake(0, posicion, 320, 150)];
    [scrollLateral setBackgroundColor:[UIColor colorWithRed: 233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0]];
    int lateral = 0;
    
    for(NSDictionary* embed in [json objectForKey:@"embeds"]){
        UIWebView* videoWebView = [constructorVistas embed:embed posicion:lateral unElemento:[[json objectForKey:@"embeds"] count]==1];
        [scrollLateral addSubview:videoWebView];
        lateral = lateral + videoWebView.frame.size.width + 5;
    }
    
    CGFloat scrollViewWidth = 0.0f;
    for (UIWebView* view in scrollLateral.subviews)
    {
        scrollViewWidth += view.frame.size.width;
    }
    [scrollLateral setContentSize:(CGSizeMake(scrollViewWidth, 150))];
    return scrollLateral;
    
}

+ (UIScrollView*)construir_scroll_images:(NSDictionary*) json posicion:(int) posicion{
    UIScrollView* scrollLateral = [[UIScrollView alloc] initWithFrame:CGRectMake(0, posicion, 320, 150)];
    [scrollLateral setBackgroundColor:[UIColor colorWithRed: 233/255.0f green:233/255.0f blue:233/255.0f alpha:1.0]];
    
    int lateral = 0;
    
    for(NSDictionary* image in [json objectForKey:@"images"]){
        UIView* imageView = [constructorVistas image:image posicion:lateral unElemento:[[json objectForKey:@"images"] count]==1];
        [scrollLateral addSubview:imageView];
        lateral = lateral + imageView.frame.size.width + 5;
    }
    
    CGFloat scrollViewWidth = 0.0f;
    for (UIWebView* view in scrollLateral.subviews)
    {
        scrollViewWidth += view.frame.size.width;
    }
    [scrollLateral setContentSize:(CGSizeMake(scrollViewWidth, 150))];
    return scrollLateral;
    
}


@end

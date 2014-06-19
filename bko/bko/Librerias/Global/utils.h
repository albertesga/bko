//
//  utils.h
//  bko
//
//  Created by Tito Español Gamón on 10/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface utils : NSObject
{
    NSString *userAllowDocName;
    NSString *userDataDocName;
}

+ (Boolean) userAllowedToUseApp;

+ (void) allowUserToUseApp:(NSString *)userName password:(NSString *)password;

+ (NSMutableDictionary *) retriveUsernamePassword;
+ (NSString *) retrieveToken;
+ (void) insertToken:(NSString *)token;
+ (BOOL)connected;
+ (NSString *) getNameKind:(NSString *) tipo;
+ (int) getKind:(NSString *) tipo;
+ (NSMutableArray*) generarContenidoDescripcion:(NSString*)contenido;
+ (NSMutableArray*)componentsSeparatedByRegex2:(NSString *)pattern string:(NSString *)text;
+ (NSString*)fechaConFormatoAgenda:(NSString*)fecha;
+ (NSString*)fechaConFormatoTituloAgenda:(NSDate*)fecha;
+ (NSString*)fechaConFormatoMensaje:(NSString*)fecha;
+ (NSDate*)stringToDate:(NSString*)fecha;
+ (NSString*)horaFromString:(NSString*)fecha;
+ (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;
+ (NSString*)quitarDecimales:(NSNumber*) precio;
+ (NSDate*)stringToDateFormatoBarras:(NSString*)fecha;
+ (void) controlarErrores:(NSError*)error;
@end

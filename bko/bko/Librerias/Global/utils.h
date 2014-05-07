//
//  utils.h
//  bko
//
//  Created by Tito Español Gamón on 10/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface utils : NSObject
{
    NSString *userAllowDocName;
    NSString *userDataDocName;
}

+ (Boolean) userAllowedToUseApp;

+ (void) allowUserToUseApp:(NSString *)userName password:(NSString *)password;

+ (NSMutableDictionary *) retriveUsernamePassword;

+ (NSString *) getNameKind:(NSString *) tipo;
+ (int) getKind:(NSString *) tipo;
+ (NSMutableArray*) generarContenidoDescripcion:(NSString*)contenido;
+ (NSMutableArray*)componentsSeparatedByRegex2:(NSString *)pattern string:(NSString *)text;
+ (NSString*)fechaConFormatoAgenda:(NSString*)fecha;
+ (NSString*)fechaConFormatoTituloAgenda:(NSDate*)fecha;
+ (NSString*)fechaConFormatoMensaje:(NSString*)fecha;
+ (NSDate*)stringToDate:(NSString*)fecha;
@end

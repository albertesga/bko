//
//  utils.m
//  bko
//
//  Created by Tito Español Gamón on 10/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "utils.h"
#import "register_dao.h"
#import "sesion.h"
#import "message_dao.h"
#import "sinConexionViewController.h"


static NSString *userAllowDocName=@"allowUse.txt";
static NSString *userDataDocName=@"userData.txt";
static NSString *tokenDataDocName=@"token.txt";

@implementation utils

+ (Boolean) userAllowedToUseApp
{
    Boolean ret=false;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSString *fileName =
    [documentsDir stringByAppendingPathComponent:userAllowDocName];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        ret=true;
    }
    return ret;
}


+ (void) allowUserToUseApp:(NSString *)userName password:(NSString *)password
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSString *fileName =
    [documentsDir stringByAppendingPathComponent:userAllowDocName];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:userName];
    [array addObject:password];
    [array writeToFile:fileName atomically:YES];
}

+ (void) insertToken:(NSString *)token
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSString *fileName =
    [documentsDir stringByAppendingPathComponent:tokenDataDocName];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:token];
    [array writeToFile:fileName atomically:YES];
}

+ (NSMutableDictionary *) retriveUsernamePassword
{
    NSMutableDictionary *ret=[[NSMutableDictionary alloc]init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSString *fileName =
    [documentsDir stringByAppendingPathComponent:userAllowDocName];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile: fileName];
        [ret setObject:[array objectAtIndex:0] forKey:@"username"];
        [ret setObject:[array objectAtIndex:1] forKey:@"password"];
    }
    return ret;
}

+ (NSString *) retriveUserName
{
    NSString *ret=@"Nombre";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSString *fileName =
    [documentsDir stringByAppendingPathComponent:userDataDocName];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile: fileName];
        ret = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
    }
    return ret;
}

+ (NSString *) retrieveToken
{
    NSString *ret=@"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSString *fileName =
    [documentsDir stringByAppendingPathComponent:tokenDataDocName];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile: fileName];
        ret = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
    }
    return ret;
}

+ (NSString *) getNameKind:(NSString *) tipo{
    if([tipo isEqualToString:@"0"]){
        return @"Artist";
    }
    if([tipo isEqualToString:@"1"]){
        return @"Sitio";
    }
    if([tipo isEqualToString:@"2"]){
        return @"Sello";
    }
    if([tipo isEqualToString:@"4"]){
        return @"Genérico";
    }
    if([tipo isEqualToString:@"5"]){
        return @"Artículo";
    }
    if([tipo isEqualToString:@"6"]){
        return @"Entrevista";
    }
    if([tipo isEqualToString:@"7"]){
        return @"Fiesta";
    }
    return @"";
}

+ (int) getKind:(NSString *) tipo{
    if([tipo isEqualToString:@"Artist"]){
        return 0;
    }
    if([tipo isEqualToString:@"Sitio"]){
        return 1;
    }
    if([tipo isEqualToString:@"Sello"]){
        return 2;
    }
    if([tipo isEqualToString:@"Genérico"]){
        return 4;
    }
    if([tipo isEqualToString:@"Artículo"]){
        return 5;
    }
    if([tipo isEqualToString:@"Entrevista"]){
        return 6;
    }
    if([tipo isEqualToString:@"Fiesta"]){
        return 7;
    }
    return -1;
}

+ (NSDate*)stringToDate:(NSString*)fecha{
    [NSLocale availableLocaleIdentifiers];
    NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
    [dfDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateEvent = [[NSDate alloc] init];
    dateEvent = [dfDate dateFromString:fecha];
    return dateEvent;
}

+ (NSDate*)stringToDateFormatoBarras:(NSString*)fecha{
    [NSLocale availableLocaleIdentifiers];
    NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
    [dfDate setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSDate *dateEvent = [[NSDate alloc] init];
    dateEvent = [dfDate dateFromString:fecha];
    return dateEvent;
}

+ (NSString*)fechaConFormatoMensaje:(NSString*)fecha{
    [NSLocale availableLocaleIdentifiers];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_es"];
    [df setLocale:locale];
    [df setDateFormat:@"MMMM"];
    [dfDate setLocale:locale];
    [dfDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateEvent = [[NSDate alloc] init];
    dateEvent = [dfDate dateFromString:fecha];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dateEvent];
    return [[[NSString stringWithFormat: @"%d", (int)[components day]] stringByAppendingString:@" "]stringByAppendingString:[df stringFromDate:dateEvent]];
}

+ (NSString*)fechaConFormatoAgenda:(NSString*)fecha{
    [NSLocale availableLocaleIdentifiers];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    NSDateFormatter* dfWeekDay = [[NSDateFormatter alloc] init];
    NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_es"];
    [df setLocale:locale];
    [df setDateFormat:@"MMMM"];
    [dfWeekDay setLocale:locale];
    [dfWeekDay setDateFormat:@"EEEE"];
    [dfDate setLocale:locale];
    [dfDate setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSDate *dateEvent = [[NSDate alloc] init];
    dateEvent = [dfDate dateFromString:fecha];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dateEvent];
    return [[[[[[dfWeekDay stringFromDate:dateEvent] substringWithRange:NSMakeRange(0, 3)] stringByAppendingString:@" "] stringByAppendingString: [NSString stringWithFormat: @"%d", (int)[components day]]] stringByAppendingString:@" " ]stringByAppendingString:[[df stringFromDate:dateEvent] substringWithRange:NSMakeRange(0, 3)]];
}

+ (NSString*)horaFromString:(NSString*)fecha{
    [NSLocale availableLocaleIdentifiers];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    [dfDate setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSDate *dateEvent = [[NSDate alloc] init];
    dateEvent = [dfDate dateFromString:fecha];
    return [df stringFromDate:dateEvent];
}

+ (NSString*)fechaConFormatoTituloAgenda:(NSDate*)fecha{
    [NSLocale availableLocaleIdentifiers];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    NSDateFormatter* dfWeekDay = [[NSDateFormatter alloc] init];
    NSDateFormatter* dfDate = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_es"];
    [df setLocale:locale];
    [df setDateFormat:@"MMMM"];
    [dfWeekDay setLocale:locale];
    [dfWeekDay setDateFormat:@"EEEE"];
    [dfDate setLocale:locale];
    [dfDate setDateFormat:@"YYYY-MM-DD"];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:fecha];
    return [[[[[dfWeekDay stringFromDate:fecha] stringByAppendingString:@" - "] stringByAppendingString:[NSString stringWithFormat: @"%d", (int)[components day]]] stringByAppendingString:@" de "] stringByAppendingString:[df stringFromDate:fecha]];
}

+ (NSMutableArray*) generarContenidoDescripcion:(NSString*)contenido{
    NSString *reg =  @"\\{\\{[^{}]*\\}\\}";
    NSMutableArray *strArray = [self componentsSeparatedByRegex2:reg string:contenido];
    return strArray;
}

+ (NSMutableArray*)componentsSeparatedByRegex2:(NSString *)pattern string:(NSString *)text
{
    NSUInteger pos = 0;
    NSRange area = NSMakeRange(0, [text length]);
    
    NSRegularExpression *regEx = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:0 error:nil];
    
    NSArray *matchResults = [regEx matchesInString:text options:0 range:area];
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:matchResults.count];
    
    for (NSTextCheckingResult *result in matchResults) {
        NSRange substrRange = NSMakeRange(pos, [result range].location-pos);
        [returnArray addObject:[text substringWithRange:substrRange]];
        [returnArray addObject:[text substringWithRange:[result range]]];
        pos = [result range].location + [result range].length;
    }
    
    if (pos < area.length) {
        [returnArray addObject:[text substringFromIndex:pos]];
    }
    
    return returnArray;
}

+ (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ( !error )
        {
            UIImage *image = [[UIImage alloc] initWithData:data];
            completionBlock(YES,image);
        } else{
            completionBlock(NO,nil);
        }
    }];
}

+ (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

+ (NSString*)quitarDecimales:(NSNumber*) precio
{
    NSNumberFormatter *twoDecimalPlacesFormatter = [[NSNumberFormatter alloc] init];
    [twoDecimalPlacesFormatter setMaximumFractionDigits:2];
    [twoDecimalPlacesFormatter setMinimumFractionDigits:0];
    
    return [twoDecimalPlacesFormatter stringForObjectValue:precio];
}

+ (void) controlarErrores:(NSError*)error{
    if(error.code == NSURLErrorTimedOut || error.code == NSURLErrorNetworkConnectionLost || [error.localizedDescription isEqualToString:@"Conexión no válida"] || error.code == -1001){
        [self login];
    }
    else{
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:[error localizedDescription]
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [theAlert show];
    }
}

+ (void) login{
    if([utils userAllowedToUseApp]){
        NSDictionary* user_pass = [utils retriveUsernamePassword];
        [[register_dao sharedInstance] login:[user_pass objectForKey:@"username"] password:[user_pass objectForKey:@"password"] token:[utils retrieveToken] y:^(NSArray *connection, NSError *error) {
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
                    } else {
                        [utils controlarErrores:error];
                    }
                }];
                
                
            } else {
                if([[error localizedDescription] isEqualToString:@"The Internet connection appears to be offline."]){
                    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"                                           bundle:nil];
                    sinConexionViewController *sinConexion =
                    [storyboard instantiateViewControllerWithIdentifier:@"sinConexionViewController"];
                    
                    UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    while (topRootViewController.presentedViewController)
                    {
                        topRootViewController = topRootViewController.presentedViewController;
                    }
                    
                    [topRootViewController presentViewController:sinConexion animated:YES completion:nil];
                    return;
                }
                
                [utils controlarErrores:error];
            }
        }];
    }
}


@end

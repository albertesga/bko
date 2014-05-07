//
//  utils.m
//  bko
//
//  Created by Tito Español Gamón on 10/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "utils.h"

static NSString *userAllowDocName=@"allowUse.txt";
static NSString *userDataDocName=@"userData.txt";

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

@end

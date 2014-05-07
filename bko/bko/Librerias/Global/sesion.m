//
//  sesion.m
//  bko
//
//  Created by Tito Español Gamón on 14/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "sesion.h"

@implementation sesion

@synthesize codigo_conexion;
@synthesize latitude;
@synthesize longitude;
@synthesize messages_unread;

+(sesion*) sharedInstance{
    static sesion* _shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    return _shared;
}

- (id)init {
    if (self = [super init]) {
        codigo_conexion = [[NSString alloc] init];
        messages_unread = [[NSNumber alloc] initWithInt:0];
        latitude = [[NSNumber alloc] initWithInt:0];
        longitude = [[NSNumber alloc] initWithInt:0];
        codigo_conexion = @"Sin inicializar";
    }
    return self;
}

@end

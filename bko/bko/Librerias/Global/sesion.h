//
//  sesion.h
//  bko
//
//  Created by Tito Español Gamón on 14/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sesion : NSObject {
    NSString *codigo_conexion;
    NSNumber *latitude;
    NSNumber *longitude;
}
@property (nonatomic,retain) NSString *codigo_conexion;
@property (nonatomic,retain) NSNumber *latitude;
@property (nonatomic,retain) NSNumber *longitude;
@property (nonatomic,retain) NSNumber *messages_unread;
+(sesion*) sharedInstance;
@end